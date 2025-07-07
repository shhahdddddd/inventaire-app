<?php

namespace App\Http\Controllers;

use App\Models\Transfert;
use App\Models\TransfertItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TransfertController extends Controller
{
    public function store(Request $request)
    {
        $user = $request->user();
        // Only Admin and Warehouse Staff can execute
        if (!($user->isAdmin() || $user->isWarehouseStaff())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validator = Validator::make($request->all(), [
            'station_source_id' => 'required|exists:station_sources,id',
            'station_destination_id' => 'required|exists:station_destinataires,id|different:station_source_id',
            'date_transfert' => 'required|date',
            'etat' => 'required|in:en_instance,valide,annule',
            'transfert_items' => 'required|array|min:1',
            'transfert_items.*.article_id' => 'required|exists:articles,id',
            'transfert_items.*.quantite' => 'required|integer|min:1',
            'transfert_items.*.prix_ht' => 'required|numeric|min:0',
            'transfert_items.*.code_barre' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        DB::beginTransaction();
        try {
            $transfert = Transfert::create(array_merge(
                $request->only([
                    'station_source_id',
                    'station_destination_id',
                    'date_transfert',
                    'etat'
                ]),
                ['store_id' => $user->store_id]
            ));

            foreach ($request->transfert_items as $item) {
                $transfertItem = new TransfertItem($item);
                $transfert->transfertItems()->save($transfertItem);
            }

            DB::commit();
            return response()->json($transfert->load(['transfertItems.article', 'stationSource', 'stationDestination']), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to create transfert: ' . $e->getMessage()], 500);
        }
    }

    public function index(Request $request)
    {
        $user = $request->user();
        // Only show transferts for the user's store
        $transferts = Transfert::where('store_id', $user->store_id)
            ->with(['transfertItems.article', 'stationSource', 'stationDestination'])
            ->get();
        // RBAC: Only Admin, Inventory Manager, Warehouse Staff can view
        if (!($user->isAdmin() || $user->isInventoryManager() || $user->isWarehouseStaff())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($transferts);
    }

    public function show($id)
    {
        $transfert = Transfert::with(['transfertItems.article', 'stationSource', 'stationDestination'])->find($id);
        if (!$transfert) {
            return response()->json(['message' => 'Transfert not found'], 404);
        }
        return response()->json($transfert);
    }

    public function update(Request $request, $id)
    {
        $transfert = Transfert::find($id);
        if (!$transfert) {
            return response()->json(['message' => 'Transfert not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'date_transfert' => 'sometimes|date',
            'station_source_id' => 'sometimes|exists:station_sources,id',
            'station_destination_id' => 'sometimes|exists:station_destinataires,id',
            'etat' => 'sometimes|in:en_attente,en_cours,termine,annule',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $transfert->update($request->all());
        return response()->json($transfert->load(['transfertItems.article', 'stationSource', 'stationDestination']));
    }

    public function destroy($id)
    {
        $transfert = Transfert::find($id);
        if (!$transfert) {
            return response()->json(['message' => 'Transfert not found'], 404);
        }

        $transfert->delete();
        return response()->json(['message' => 'Transfert deleted successfully']);
    }
}

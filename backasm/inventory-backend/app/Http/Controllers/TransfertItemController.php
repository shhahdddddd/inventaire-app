<?php

namespace App\Http\Controllers;

use App\Models\TransfertItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TransfertItemController extends Controller
{
    public function index(Request $request, $transfert_id)
    {
        $user = $request->user();
        $transfert = \App\Models\Transfert::where('id', $transfert_id)->where('store_id', $user->store_id)->first();
        if (!$transfert) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // RBAC: Only Admin, Inventory Manager, Warehouse Staff can view
        if (!($user->isAdmin() || $user->isInventoryManager() || $user->isWarehouseStaff())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $items = TransfertItem::with('article')->where('transfert_id', $transfert_id)->get();
        return response()->json($items);
    }

    public function show($transfert_id, $id)
    {
        $item = TransfertItem::with('article')->where('transfert_id', $transfert_id)->find($id);
        if (!$item) {
            return response()->json(['message' => 'Item not found'], 404);
        }
        return response()->json($item);
    }

    public function store(Request $request, $transfert_id)
    {
        $user = $request->user();
        $transfert = \App\Models\Transfert::where('id', $transfert_id)->where('store_id', $user->store_id)->first();
        if (!$transfert) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // Only Admin and Warehouse Staff can add items
        if (!($user->isAdmin() || $user->isWarehouseStaff())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validator = \Validator::make($request->all(), [
            'article_id' => 'required|exists:articles,id',
            'quantite_transferer' => 'required|integer|min:1',
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $item = new TransfertItem($request->all());
        $item->transfert_id = $transfert_id;
        $item->save();
        return response()->json($item->load('article'), 201);
    }

    public function update(Request $request, $transfert_id, $id)
    {
        $item = TransfertItem::where('transfert_id', $transfert_id)->find($id);
        if (!$item) {
            return response()->json(['message' => 'Item not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'article_id' => 'sometimes|exists:articles,id',
            'quantite_transferer' => 'sometimes|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $item->update($request->all());
        return response()->json($item->load('article'));
    }

    public function destroy($transfert_id, $id)
    {
        $item = TransfertItem::where('transfert_id', $transfert_id)->find($id);
        if (!$item) {
            return response()->json(['message' => 'Item not found'], 404);
        }

        $item->delete();
        return response()->json(['message' => 'Item deleted successfully']);
    }
}

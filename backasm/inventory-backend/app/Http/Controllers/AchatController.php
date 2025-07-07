<?php

namespace App\Http\Controllers;

use App\Models\Achat;
use App\Models\AchatItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AchatController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        // Only show achats for the user's store
        $achats = Achat::where('store_id', $user->store_id)
            ->with(['fournisseur', 'achatItems.article'])
            ->get();
        // RBAC: Only Admin, Purchasing Officer, Inventory Manager can view
        if (!($user->isAdmin() || $user->isPurchasingOfficer() || $user->isInventoryManager())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($achats);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        // Only Admin and Purchasing Officer can create
        if (!($user->isAdmin() || $user->isPurchasingOfficer())) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validated = $request->validate([
            'type_piece' => 'required|in:BL,Facture',
            'num_piece' => 'required|string|max:100',
            'date_achat' => 'required|date',
            'fournisseur_nom' => 'required|string|exists:fournisseurs,name',
            'station_id' => 'required|integer|exists:station_source,id',
            'achat_items' => 'required|array|min:1',
            'achat_items.*.article_id' => 'required|integer|exists:articles,id',
            'achat_items.*.quantite' => 'required|integer|min:1',
            'achat_items.*.prix_ht' => 'required|numeric|min:0',
            'achat_items.*.tva' => 'required|numeric|min:0',
            'achat_items.*.prix_ttc' => 'required|numeric|min:0',
        ]);
        $validated['store_id'] = $user->store_id;
        DB::beginTransaction();
        try {
            $achat = Achat::create($validated);
            foreach ($request->achat_items as $item) {
                $achatItem = new AchatItem($item);
                $achat->achatItems()->save($achatItem);
            }
            DB::commit();
            return response()->json($achat->load('achatItems'), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to create achat: ' . $e->getMessage()], 500);
        }
    }

    // ... other methods (show, update, destroy) can be added as needed
}

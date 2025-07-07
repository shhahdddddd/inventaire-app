<?php

namespace App\Http\Controllers;

use App\Models\AchatItem;
use Illuminate\Http\Request;

class AchatItemController extends Controller
{
    public function index()
    {
        $achatItems = AchatItem::all();
        return response()->json($achatItems);
    }

    public function show($id)
    {
        $achatItem = AchatItem::findOrFail($id);
        return response()->json($achatItem);
    }

    // We may not need store, update, destroy if we are managing items through AchatController
}

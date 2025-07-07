<?php

namespace App\Http\Controllers;

use App\Models\Article;
use Illuminate\Http\Request;

class ArticleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Article::where('store_id', $user->store_id);
        if ($request->has('famille')) {
            $query->where('famille', $request->famille);
        }
        if ($request->has('marque')) {
            $query->where('marque', $request->marque);
        }
        return $query->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $user = auth()->user();
        $validatedData = $request->validate([
            'designation' => 'required|string|max:255',
            'reference' => 'required|string|max:255|unique:article',
            'prix_achat' => 'required|numeric',
            'prix_vente' => 'required|numeric',
            'quantite_stock' => 'required|integer',
            'prix_ttc' => 'required|numeric',
            'famille' => 'required|string|max:255',
            'marque' => 'required|string|max:255',
            'type_prix' => 'required|string|max:255',
            'tva' => 'required|numeric',
        ]);
        $validatedData['store_id'] = $user->store_id;
        $article = Article::create($validatedData);
        return response()->json($article, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Article $article)
    {
        $user = auth()->user();
        if ($article->store_id !== $user->store_id) {
            abort(403, 'Unauthorized');
        }
        return $article;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Article $article)
    {
        $user = auth()->user();
        if ($article->store_id !== $user->store_id) {
            abort(403, 'Unauthorized');
        }
        $validatedData = $request->validate([
            'designation' => 'string|max:255',
            'reference' => 'string|max:255|unique:article,reference,'.$article->id,
            'prix_achat' => 'numeric',
            'prix_vente' => 'numeric',
            'quantite_stock' => 'integer',
            'prix_ttc' => 'numeric',
            'famille' => 'string|max:255',
            'marque' => 'string|max:255',
            'type_prix' => 'string|max:255',
            'tva' => 'numeric',
        ]);
        $article->update($validatedData);
        return response()->json($article);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Article $article)
    {
        $user = auth()->user();
        if ($article->store_id !== $user->store_id) {
            abort(403, 'Unauthorized');
        }
        $article->delete();
        return response()->json(null, 204);
    }
}

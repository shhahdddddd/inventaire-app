<?php

namespace App\Observers;

use App\Models\Achat;

class AchatObserver
{
    /**
     * Handle the Achat "created" event.
     */
    public function created(Achat $achat): void
    {
        //
    }

    /**
     * Handle the Achat "updated" event.
     */
    public function updated(Achat $achat): void
    {
        //
    }

    /**
     * Handle the Achat "deleted" event.
     */
    public function deleted(Achat $achat): void
    {
        //
    }

    /**
     * Handle the Achat "restored" event.
     */
    public function restored(Achat $achat): void
    {
        //
    }

    /**
     * Handle the Achat "force deleted" event.
     */
    public function forceDeleted(Achat $achat): void
    {
        //
    }
}

<?php

namespace App\Filament\Resources\FechaDestacadaResource\Pages;

use App\Filament\Resources\FechaDestacadaResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditFechaDestacada extends EditRecord
{
    protected static string $resource = FechaDestacadaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}

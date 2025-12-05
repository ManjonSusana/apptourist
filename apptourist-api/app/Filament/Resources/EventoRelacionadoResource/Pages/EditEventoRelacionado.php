<?php

namespace App\Filament\Resources\EventoRelacionadoResource\Pages;

use App\Filament\Resources\EventoRelacionadoResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditEventoRelacionado extends EditRecord
{
    protected static string $resource = EventoRelacionadoResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}

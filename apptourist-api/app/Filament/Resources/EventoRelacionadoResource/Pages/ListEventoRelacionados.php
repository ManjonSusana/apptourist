<?php

namespace App\Filament\Resources\EventoRelacionadoResource\Pages;

use App\Filament\Resources\EventoRelacionadoResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListEventoRelacionados extends ListRecords
{
    protected static string $resource = EventoRelacionadoResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}

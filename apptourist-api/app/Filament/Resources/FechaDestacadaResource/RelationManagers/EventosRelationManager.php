<?php

namespace App\Filament\Resources\FechaDestacadaResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Resources\RelationManagers\RelationManager;

class EventosRelationManager extends RelationManager
{
    protected static string $relationship = 'eventos';

    protected static ?string $title = 'Eventos Relacionados';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('titulo')
                    ->label('Título del Evento')
                    ->required()
                    ->maxLength(255),

                Forms\Components\Textarea::make('descripcion')
                    ->label('Descripción')
                    ->required()
                    ->rows(3),

                Forms\Components\TextInput::make('ubicacion')
                    ->label('Ubicación')
                    ->required()
                    ->maxLength(255),

                Forms\Components\DateTimePicker::make('fechaHoraInicio')
                    ->label('Fecha y Hora')
                    ->required()
                    ->seconds(false),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('titulo')
                    ->label('Título')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('ubicacion')
                    ->label('Ubicación')
                    ->searchable(),

                Tables\Columns\TextColumn::make('fechaHoraInicio')
                    ->label('Fecha / Hora')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Creado')
                    ->dateTime('d/m/Y'),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->label('Agregar Evento'),
            ])
            ->actions([
                Tables\Actions\EditAction::make()->label('Editar'),
                Tables\Actions\DeleteAction::make()->label('Eliminar'),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }
}

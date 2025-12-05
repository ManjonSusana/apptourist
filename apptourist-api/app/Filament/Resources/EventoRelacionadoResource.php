<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EventoRelacionadoResource\Pages;
use App\Models\EventoRelacionado;
use App\Models\FechaDestacada;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class EventoRelacionadoResource extends Resource
{
    protected static ?string $model = EventoRelacionado::class;

    protected static ?string $navigationIcon = 'heroicon-o-sparkles';
    protected static ?string $navigationLabel = 'Eventos relacionados';
    protected static ?string $pluralModelLabel = 'Eventos relacionados';
    protected static ?string $modelLabel = 'Evento relacionado';
    protected static ?int $navigationSort = 5;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Relación con fecha destacada')
                    ->schema([
                        Forms\Components\Select::make('hitoId')
                            ->label('Fecha destacada')
                            ->options(
                                FechaDestacada::orderBy('fechaInicio', 'asc')
                                    ->pluck('titulo', 'id')
                            )
                            ->searchable()
                            ->required(),
                    ])
                    ->columns(1),

                Forms\Components\Section::make('Detalles del evento')
                    ->schema([
                        Forms\Components\TextInput::make('titulo')
                            ->label('Título')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Textarea::make('descripcion')
                            ->label('Descripción')
                            ->rows(3),

                        Forms\Components\TextInput::make('ubicacion')
                            ->label('Ubicación')
                            ->placeholder('Plaza 25 de Mayo, Teatro Gran Mariscal, etc.')
                            ->required(),

                        Forms\Components\DateTimePicker::make('fechaHoraInicio')
                            ->label('Fecha y hora de inicio')
                            ->required(),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('fechaDestacada.titulo')
                    ->label('Fecha destacada')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('titulo')
                    ->label('Evento')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('ubicacion')
                    ->label('Ubicación')
                    ->searchable(),

                Tables\Columns\TextColumn::make('fechaHoraInicio')
                    ->label('Fecha y hora')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('hitoId')
                    ->label('Fecha destacada')
                    ->options(
                        FechaDestacada::orderBy('fechaInicio', 'asc')
                            ->pluck('titulo', 'id')
                    ),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListEventoRelacionados::route('/'),
            'create' => Pages\CreateEventoRelacionado::route('/create'),
            'edit'   => Pages\EditEventoRelacionado::route('/{record}/edit'),
        ];
    }
}

<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FechaDestacadaResource\Pages;
use App\Models\FechaDestacada;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class FechaDestacadaResource extends Resource
{
    protected static ?string $model = FechaDestacada::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?string $navigationLabel = 'Fechas destacadas';
    protected static ?string $pluralModelLabel = 'Fechas destacadas';
    protected static ?string $modelLabel = 'Fecha destacada';
    protected static ?int $navigationSort = 4;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Información principal')
                    ->schema([
                        Forms\Components\TextInput::make('titulo')
                            ->label('Título')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Textarea::make('descripcion')
                            ->label('Descripción')
                            ->rows(3),

                        Forms\Components\TextInput::make('icono')
                            ->label('Icono (emoji o texto)')
                            ->maxLength(10)
                            ->placeholder('🎉'),

                        Forms\Components\Select::make('categoria')
                            ->label('Categoría')
                            ->options([
                                'Festividades y Tradiciones' => 'Festividades y Tradiciones',
                                'Arte y Cultura'             => 'Arte y Cultura',
                                'Sociedad y Reivindicación'  => 'Sociedad y Reivindicación',
                                'Gastronomía y Ferias'       => 'Gastronomía y Ferias',
                            ])
                            ->required(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Fechas y visuales')
                    ->schema([
                        Forms\Components\DatePicker::make('fechaInicio')
                            ->label('Fecha inicio')
                            ->required(),

                        Forms\Components\DatePicker::make('fechaFin')
                            ->label('Fecha fin')
                            ->helperText('Puedes dejarla vacía si es un solo día.'),

                        Forms\Components\Toggle::make('permanente')
                            ->label('Es permanente (todo el año)')
                            ->inline(false),

                        Forms\Components\TextInput::make('imagenAsset')
                            ->label('Imagen (asset)')
                            ->placeholder('assets/fechas/navidad.jpg'),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('titulo')
                    ->label('Título')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('categoria')
                    ->label('Categoría')
                    ->sortable(),

                Tables\Columns\TextColumn::make('fechaInicio')
                    ->label('Inicio')
                    ->date('d/m/Y')
                    ->sortable(),

                Tables\Columns\TextColumn::make('fechaFin')
                    ->label('Fin')
                    ->date('d/m/Y')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\IconColumn::make('permanente')
                    ->label('Permanente')
                    ->boolean(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Creado')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('categoria')
                    ->options([
                        'Festividades y Tradiciones' => 'Festividades y Tradiciones',
                        'Arte y Cultura'             => 'Arte y Cultura',
                        'Sociedad y Reivindicación'  => 'Sociedad y Reivindicación',
                        'Gastronomía y Ferias'       => 'Gastronomía y Ferias',
                    ]),
                Tables\Filters\TernaryFilter::make('permanente')
                    ->label('Solo permanentes'),
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
            'index'  => Pages\ListFechaDestacadas::route('/'),
            'create' => Pages\CreateFechaDestacada::route('/create'),
            'edit'   => Pages\EditFechaDestacada::route('/{record}/edit'),
        ];
    }
}

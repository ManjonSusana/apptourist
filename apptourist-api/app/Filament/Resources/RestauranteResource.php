<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RestauranteResource\Pages;
use App\Models\Restaurante;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class RestauranteResource extends Resource
{
    protected static ?string $model = Restaurante::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-storefront';
    protected static ?string $navigationLabel = 'Restaurantes';
    protected static ?string $pluralModelLabel = 'Restaurantes';
    protected static ?string $modelLabel = 'Restaurante';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Información del restaurante')
                    ->schema([
                        Forms\Components\TextInput::make('nombre')
                            ->label('Nombre')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('direccion')
                            ->label('Dirección')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Select::make('categoria')
                            ->label('Categoría')
                            ->options([
                                'tradicional' => 'Tradicional',
                                'gourmet'     => 'Gourmet',
                                'rápida'      => 'Comida rápida',
                                'otro'        => 'Otro',
                            ])
                            ->required(),

                        Forms\Components\Textarea::make('descripcion')
                            ->label('Descripción')
                            ->rows(3),

                        Forms\Components\TextInput::make('imagenAsset')
                            ->label('Imagen principal (asset)')
                            ->placeholder('assets/restaurantes/mi_restaurante.jpg'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Extras')
                    ->schema([
                        Forms\Components\TextInput::make('rating')
                            ->numeric()
                            ->minValue(0)
                            ->maxValue(5)
                            ->step(0.1)
                            ->default(4.0)
                            ->label('Rating'),

                        Forms\Components\KeyValue::make('imagenes')
                            ->label('Otras imágenes (opcional)')
                            ->keyLabel('Clave')
                            ->valueLabel('Ruta del asset'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable(),

                Tables\Columns\TextColumn::make('nombre')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('direccion')
                    ->label('Dirección')
                    ->searchable(),

                Tables\Columns\BadgeColumn::make('categoria')
                    ->label('Categoría')
                    ->colors([
                        'primary',
                        'success' => 'tradicional',
                        'warning' => 'gourmet',
                    ]),

                Tables\Columns\TextColumn::make('rating')
                    ->label('Rating')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Creado')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('categoria')
                    ->options([
                        'tradicional' => 'Tradicional',
                        'gourmet'     => 'Gourmet',
                        'rápida'      => 'Comida rápida',
                        'otro'        => 'Otro',
                    ]),
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
            'index'  => Pages\ListRestaurantes::route('/'),
            'create' => Pages\CreateRestaurante::route('/create'),
            'edit'   => Pages\EditRestaurante::route('/{record}/edit'),
        ];
    }
}

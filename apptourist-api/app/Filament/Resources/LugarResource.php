<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LugarResource\Pages;
use App\Models\Lugar;
use Filament\Forms;
use Filament\Forms\Form;     // 👈 Form correcto en v3
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;   // 👈 Table correcto en v3

class LugarResource extends Resource
{
    protected static ?string $model = Lugar::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office';
    protected static ?string $navigationLabel = 'Lugares';
    protected static ?string $pluralModelLabel = 'Lugares';
    protected static ?string $modelLabel = 'Lugar';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Información principal')
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
                                'caro' => 'Caro',
                                'economico' => 'Económico',
                                'otro' => 'Otro',
                            ])
                            ->required(),

                        Forms\Components\Textarea::make('descripcion')
                            ->label('Descripción')
                            ->rows(3),

                        Forms\Components\TextInput::make('imagenAsset')
                            ->label('Imagen principal (asset)')
                            ->placeholder('assets/lugares/mi_lugar.jpg'),
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

                        // Si tu columna "imagenes" es TEXT/JSON, puedes usar esto:
                        Forms\Components\KeyValue::make('imagenes')
                            ->label('Otras imágenes (opcional)')
                            ->keyLabel('Clave (ej: img1, img2)')
                            ->valueLabel('Ruta del asset'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->sortable()
                    ->label('ID'),

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
                        'success' => 'economico',
                        'warning' => 'caro',
                    ])
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'caro' => 'Caro',
                        'economico' => 'Económico',
                        default => 'Otro',
                    }),

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
                        'caro' => 'Caro',
                        'economico' => 'Económico',
                        'otro' => 'Otro',
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
            'index'  => Pages\ListLugars::route('/'),
            'create' => Pages\CreateLugar::route('/create'),
            'edit'   => Pages\EditLugar::route('/{record}/edit'),
        ];
    }
}

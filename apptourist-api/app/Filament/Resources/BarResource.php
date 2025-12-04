<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BarResource\Pages;
use App\Models\Bar;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class BarResource extends Resource
{
    protected static ?string $model = Bar::class;

    protected static ?string $navigationIcon = 'heroicon-o-home-modern';
    protected static ?string $navigationLabel = 'Bares';
    protected static ?string $pluralModelLabel = 'Bares';
    protected static ?string $modelLabel = 'Bar';
    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Información del bar')
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
                                'pub'       => 'Pub',
                                'karaoke'   => 'Karaoke',
                                'discoteca' => 'Discoteca',
                                'coctelería'=> 'Coctelería',
                                'otro'      => 'Otro',
                            ])
                            ->required(),

                        Forms\Components\Textarea::make('descripcion')
                            ->label('Descripción')
                            ->rows(3),

                        Forms\Components\TextInput::make('imagenAsset')
                            ->label('Imagen principal (asset)')
                            ->placeholder('assets/bares/mi_bar.jpg'),
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
                        'warning' => 'pub',
                        'success' => 'karaoke',
                        'danger'  => 'discoteca',
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
                        'pub'       => 'Pub',
                        'karaoke'   => 'Karaoke',
                        'discoteca' => 'Discoteca',
                        'coctelería'=> 'Coctelería',
                        'otro'      => 'Otro',
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
            'index'  => Pages\ListBars::route('/'),
            'create' => Pages\CreateBar::route('/create'),
            'edit'   => Pages\EditBar::route('/{record}/edit'),
        ];
    }
}

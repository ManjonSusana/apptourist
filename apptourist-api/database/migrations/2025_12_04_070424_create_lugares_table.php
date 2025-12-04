<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
public function up(): void
{
    Schema::create('lugares', function (Blueprint $table) {
        $table->id();
        $table->string('nombre');
        $table->text('descripcion')->nullable();
        $table->string('direccion')->nullable();

        // caro / economico
        $table->string('categoria')->nullable();

        // ej: 'lugar'
        $table->string('tipo')->nullable();

        // ruta imagen principal
        $table->string('imagenAsset')->nullable();

        // rating 0–5, un decimal
        $table->decimal('rating', 2, 1)->default(3.5);

        // JSON con 4 imágenes
        $table->text('imagenes')->nullable();

        // horario (texto)
        $table->string('horario')->nullable();

        // coordenadas
        $table->double('latitud')->nullable();
        $table->double('longitud')->nullable();

        $table->timestamps();
    });
}



    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('lugares');
    }
};

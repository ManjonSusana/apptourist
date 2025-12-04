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
    Schema::create('bares', function (Blueprint $table) {
        $table->id();
        $table->string('nombre');
        $table->text('descripcion')->nullable();
        $table->string('direccion')->nullable();

        // premium / elegante / popular / etc.
        $table->string('ambiente')->nullable();

        $table->string('imagenAsset')->nullable();
        $table->decimal('rating', 2, 1)->default(3.5);
        $table->text('imagenes')->nullable(); // JSON
        $table->string('horario')->nullable();
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
        Schema::dropIfExists('bares');
    }
};

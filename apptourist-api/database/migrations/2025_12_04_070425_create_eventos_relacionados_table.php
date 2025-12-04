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
    Schema::create('eventos_relacionados', function (Blueprint $table) {
        $table->id();

        $table->unsignedBigInteger('hitoId'); // referencia a fechas_destacadas.id
        $table->string('titulo');
        $table->text('descripcion')->nullable();
        $table->string('ubicacion')->nullable();
        $table->dateTime('fechaHoraInicio');

        $table->timestamps();

        $table->foreign('hitoId')
            ->references('id')
            ->on('fechas_destacadas')
            ->onDelete('cascade');
    });
}



    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('eventos_relacionados');
    }
};

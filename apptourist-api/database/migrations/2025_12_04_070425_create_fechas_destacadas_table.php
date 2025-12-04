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
    Schema::create('fechas_destacadas', function (Blueprint $table) {
        $table->id();
        $table->string('titulo');
        $table->text('descripcion')->nullable();
        $table->string('icono')->nullable();
        $table->string('categoria')->nullable();

        // Guardas ISO8601 (con fecha y hora)
        $table->dateTime('fechaInicio');
        $table->dateTime('fechaFin')->nullable();

        // 0 = no, 1 = sí
        $table->boolean('permanente')->default(false);

        $table->string('imagenAsset')->nullable();

        $table->timestamps();
    });
}



    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('fechas_destacadas');
    }
};

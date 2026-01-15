\# 🏎️ Juego Carretera - Coche en VHDL (Nexys A7 100T)



Este repositorio contiene el diseño completo en VHDL con Vivado de un videojuego de vehículos, implementado para la placa de desarrollo FPGA \*\*Nexys A7 100T\*\*. El juego consiste en conducir un vehículo a través de una carretera que cambia dinámicamente, evitando colisionar con los bordes mientras se progresa hasta la meta.



\## 👥 Equipo de Desarrollo

El proyecto ha sido desarrollado de forma colaborativa por:

\* \*\*Andrés Galindo Gordon\*\*: Diseño e implementación de la Máquina de Estados (\*\*FSM\*\*).

\* \*\*Sergio Llana Ayén\*\*: Diseño e implementación del controlador de entradas (\*\*Input Controller\*\*).

\* \*\*Marina Moreno Hernández\*\*: Diseño e implementación del controlador de salidas (\*\*Output Controller\*\*).

\* \*\*Colaboración Conjunta\*\*: Diseño e implementación de la lógica del juego  (\*\*Game Logic\*\*) y el diseño e integración del sistema completo en el módulo \*\*TOP\_JUEGO\*\*.



\## 🎮 Descripción del Juego

El objetivo es mantener el vehículo dentro de los límites de una carretera que se mueve de forma aleatoria. El jugador debe reaccionar rápidamente para no chocar.



\### Características principales:

\* \*\*Visualización en Display\*\*: La carretera y el coche/moto se visualizan a través de los displays de 7 segmentos de la placa.

\* \*\*Dificultad Ajustable\*\*: Mediante switches (`DIFICULTAD\_SW`), el usuario puede seleccionar entre niveles:

&nbsp;   \* \*\*Fácil\*\*: Velocidad reducida.

&nbsp;   \* \*\*Medio\*\*: Velocidad intermedia.

&nbsp;   \* \*\*Difícil\*\*: Velocidad máxima.

\* \*\*Selección de Vehículo\*\*: Se puede elegir mediante un switch (`TIPO\_V\_SW`) entre:

&nbsp;   \* \*\*Coche\*\*: Dibujado como un '0' teniendo menos rango de movimiento (salto de 2 posiciones).

&nbsp;   \* \*\*Moto\*\*: Dibujado como un '1' teniendo un movimiento más preciso (salto de 1 posición).

\* \*\*Progreso Visual\*\*: Una barra de 16 LEDs indica el avance hacia la meta.

\* \*\*Feedback Sonoro\*\*: Un buzzer emite tonos específicos al ganar, perder o cambiar configuraciones.



\## 🛠️ Arquitectura del Sistema

El diseño sigue una estructura modular jerárquica:



1\. \*\*TOP\_JUEGO\*\*: Módulo de nivel superior que interconecta todos los componentes.

2\. \*\*Input\_Manager\*\*: Gestiona botones y switches, incluyendo módulos de sincronización, antirrebotes (debouncer) y detección de flancos.

3\. \*\*FSM\*\*: Controla el flujo del juego (estados: `MENU`, `GAME`, `LOSE`, `WIN`).

4\. \*\*Game\_Logic\*\*: Motor del juego que gestiona el movimiento de la carretera, las colisiones y el contador de progreso.

5\. \*\*Output\_Controller\*\*: Centraliza la salida hacia los displays, LEDs y el controlador del buzzer.



\## 🚀 Controles

\* \*\*BTN\_START\*\*: Inicia la partida o reinicia tras finalizar.

\* \*\*BTN\_L / BTN\_R\*\*: Mueven el vehículo hacia la izquierda o derecha.

\* \*\*SW\_VEHICLE\*\*: Cambia el tipo de vehículo (Coche/Moto).

\* \*\*DIFICULTAD\_SW\*\*: Configura la velocidad de la carretera.



---

\*Proyecto realizado como parte de la asignatura de Sistemas Electrónicos digitales.\*


vagrant-dnie
============

Puesta en marcha rápida de un navegador Firefox con todo lo necesario para utilizar el DNI electrónico.

Vagrant y Chef se encargan de descargar, instalar y aprovisionar una máquina virtual de VirtualBox basada en Ubuntu Precise Pangolin.

Se trata de un sistema minimalista con un gestor de ventanas ligero (OpenBox) y un Firefox con todos los certificados y módulos necesarios para utilizar el DNIe.


Instalación y uso
-----------------

1. Descarga e instala [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
2. Instala [Vagrant](http://downloads.vagrantup.com)
3. Clona este repo
3. Ejecuta `vagrant up`. La primera ejecución lleva un buen rato
   (tiene que descargar la imagen y todos los paquetes, compilar, etc). 
   Espera a que termine antes de iniciar sesión.
4. Conecta el lector de DNIe
5. Inicia sesión en la ventana de Virtualbox con user `vagrant` y password `vagrant`.
6. Ejecuta `startx`.
7. Listo!

Para detener la máquina virtual: `vagrant halt`
Para volver a lanzarla: `vagrant up`. Los arranques consecutivos serán mucho más rápidos que el primero.

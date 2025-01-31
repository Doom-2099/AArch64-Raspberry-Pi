#include <stdio.h>
#include <pigpio.h>

int main() {
    if(gpioInitialise() < 0) {
        printf("Error: GPIO initialization failed\n");
        return 1;
    }

    int pin = 17;

    // Configurar El Pin Como Salida
    gpioSetMode(pin, PI_OUTPUT);

    // Colocar Un Estado Alto En El Pin
    gpioWrite(pin, 1);
    printf("Pin %d set to HIGH\n", pin);

    // Esperar 2 Segundos
    time_sleep(2);

    // Colocar Un Estado Bajo En El Pin
    gpioWrite(pin, 0);
    printf("Pin %d set to LOW\n", pin);

    gpioTerminate();

    return 0;
}

// encender el daemon de pigpio
// sudo pigpiod

// comando para compilar
// gcc -0 gpio_control gpio_control.c -lpigpio -lrt -pthread

// detener el daemon de pigpio
// sudo killall pigpiod

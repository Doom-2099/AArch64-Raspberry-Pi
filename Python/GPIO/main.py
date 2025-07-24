import RPi.GPIO as GPIO #type: ignore
import time # type: ignore
import random # type: ignore

GPIO.setMode(GPIO.BCM)

GPIO.setup(23, GPIO.OUT)
GPIO.setup(24, GPIO.OUT)
GPIO.setup(25, GPIO.OUT)

pines = [23, 24, 25]

def decimal_binario(decimal):
    if not (0 <= decimal <= 7):
        raise ValueError("El número debe estar entre 0 y 7")
    binario = [int(bit) for bit in format (decimal, '03b')]
    return binario

def write_binario(decimal):
    bits = decimal_binario(decimal)
    for pin, bit in zip(pines, bits):
        GPIO.output(pin, bit)
    print(f"Escribiendo {bits} en los pines: {pines}")


def main():
    try:
        while True:
            num = random.randint(0, 7)
            write_binario(num)
            time.sleep(0.2)
            write_binario(7)
            
    except KeyboardInterrupt:
        print("Programa interrumpido por el usuario.")

    finally:
        GPIO.cleanup()
        print("Limpieza de GPIO completada.")


if __name__ == "__main__":
    main()
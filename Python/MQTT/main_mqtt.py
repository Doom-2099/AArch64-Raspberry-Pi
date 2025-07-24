import os
from paho.mqtt import client as mqtt
from dotenv import load_dotenv
import time

load_dotenv()

broker = None

def start_connection():
    try:
        global broker
        
        # * Configurar las credenciales del broker MQTT
        broker = mqtt.Client()
        broker.tls_set(tls_version=mqtt.ssl.PROTOCOL_TLS)
        broker.username_pw_set(os.getenv('MQTT_USERNAME'), os.getenv('MQTT_PASSWORD'))

        # * utilizando funciones lambda para definir los callbacks
        # broker.on_connect = lambda broker, userdata, flags, rc: print(f"Connected with result code {rc}")
        # broker.on_message = lambda broker, userdata, msg: print(f"Message received: {msg.topic} {msg.payload}")
        broker.on_connect = on_connect
        broker.on_message = on_message

        # * Conectar al broker MQTT
        broker.connect(os.getenv('MQTT_BROKER'), int(os.getenv('MQTT_PORT', 8883)), 60)
        broker.loop_start()
        return True

    except Exception as e:
        print(f"Error starting MQTT connection: {e}")
        return False
    
# ! Metodos para los callbacks
def on_connect(broker, userdata, flags, rc):
    try:
        if rc == 0:
            print(f"[MQTT] Conectado con resultado: {rc}")
            broker.subscribe(os.getenv("MQTT_TOPIC_SUB"), qos=0)
            print(f"[MQTT] Suscrito al tópico: {os.getenv('MQTT_TOPIC_SUB')}")
            return True
        else:
            return False
    except Exception as e:
        print(f"Error in on_connect_method: {e}")
        return False
    
def on_message(broker, userdata, msg):
    try:
        print(f"[MQTT] Mensaje recibido: {msg.topic} {msg.payload.decode()}")
        # Aquí puedes agregar lógica para procesar el mensaje recibido
    except Exception as e:
        print(f"Error in on_message_method: {e}")

def publish_message(message):
    global broker
    try:
        if broker.is_connected():
            broker.publish(os.getenv("MQTT_TOPIC_PUB"), message, qos=0)
            return True
        else:
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False
    

def main(start):
    try:
        while True:
            if (int(time.monotonic() * 1000) - start) > 5000:
                publish_message("Hello from MQTT!")
                start = int(time.monotonic() * 1000)
                
    except Exception as e:
        print(f"Error in main method: {e}")

# ! use => pip install paho-mqtt < 2.0.0


if __name__ == "__main__":
    start_connection()
    start = int(time.monotonic() * 1000)
    main(start)
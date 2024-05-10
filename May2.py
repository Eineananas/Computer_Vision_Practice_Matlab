
import paho.mqtt.client as mqtt
# MQTT 代理的连接参数
broker = "mqtt.example.com"
port = 1883
username = "your_username"
password = "your_password"
topic = "your_topic"

# 定义回调函数，在连接成功时被调用
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT broker")
    # 订阅主题
    client.subscribe(topic)

# 定义回调函数，在接收到消息时被调用
def on_message(client, userdata, msg):
    print(f"Received message: {msg.payload.decode()}")

# 创建 MQTT 客户端实例
client = mqtt.Client()

# 设置连接回调函数
client.on_connect = on_connect

# 设置消息回调函数
client.on_message = on_message

# 设置用户名和密码（如果需要）
client.username_pw_set(username, password)

# 连接到 MQTT 代理
client.connect(broker, port)

# 保持连接
client.loop_forever()

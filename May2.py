May 10th
MQTT (Message Queuing Telemetry Transport) 是一种轻量级的通信协议，用于在物联网（IoT）和其他网络应用中进行消息传输。
它是基于发布-订阅模式的协议，允许设备和应用程序通过中间代理（通常称为 MQTT 代理或 MQTT 服务器）进行异步通信。

MQTT 设计的目标是在带宽有限、网络不稳定以及计算能力有限的环境下实现高效的消息传递。
它使用简单的消息发布和订阅机制，通过订阅者订阅感兴趣的主题（Topic），当发布者发布消息到对应的主题时，订阅者就可以接收到这些消息。
这种松散耦合的通信方式使得 MQTT 成为物联网设备和应用程序之间进行可靠、实时通信的理想选择。

以下是 MQTT 的一些关键特点：

1. 轻量级：MQTT 协议设计简洁，消息头部占用较小的数据量，使得它适用于带宽有限的环境。
2. 异步通信：MQTT 使用异步通信模式，发布者和订阅者之间不需要直接建立连接，可以通过 MQTT 代理进行中转，从而实现解耦和灵活的通信。
3. 消息发布和订阅：MQTT 使用发布-订阅模式，发布者将消息发布到特定的主题（Topic），而订阅者通过订阅感兴趣的主题来接收消息。
4. QoS (Quality of Service)：MQTT 支持多个层次的消息传输质量保证，包括至多一次（QoS 0）、至少一次（QoS 1）和只有一次（QoS 2）三种级别，根据需求选择适当的 QoS 级别来确保消息的可靠性和交付顺序。
5. 保留消息：MQTT 允许发布者发布保留消息，即最新的消息将保留在代理中，新的订阅者可以立即接收到该消息，而不仅仅是在发布时才能接收。
MQTT 协议被广泛应用于物联网领域，包括传感器网络、远程监控、智能家居、工业自动化等场景，它提供了一种可靠、高效的消息传输方式，适用于各种规模和复杂度的应用。

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

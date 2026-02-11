#!/bin/bash
# SNotice API 测试脚本

# 测试发送通知
curl -X POST http://localhost:8642/api/notify \
	-H "Content-Type: application/json" \
	-d '{
    "title": "测试通知",
    "body": "这是来自 SNotice 的测试通知",
    "priority": "high"
  }'

# 测试闪屏通知
curl -X POST http://localhost:8642/api/notify \
	-H "Content-Type: application/json" \
	-d '{
    "title": "测试通知",
    "body": "这是来自 SNotice 的测试通知",
    "priority": "high"
  }'

# 获取服务状态
curl http://localhost:8642/api/status

# 获取配置
curl http://localhost:8642/api/config

# 更新配置
curl -X POST http://localhost:8642/api/config \
	-H "Content-Type: application/json" \
	-d '{
    "port": 8642,
    "allowedIPs": ["127.0.0.1", "::1"],
    "autoStart": true,
    "showNotifications": true
  }'

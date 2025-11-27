# Cost Tracking - Zero-Cost Validation Plan

## Objective

Document the costs (and savings) of running the Xwift local testnet on solar power and free WiFi to maintain zero marginal costs.

---

## Hardware (One-Time)

| Component             | Cost    | Notes                                |
|-----------------------|---------|--------------------------------------|
| AMD Ryzen 5 7600 CPU  | $229    | Already owned                        |
| 32GB DDR5 RAM         | $120    | Already owned                        |
| 1TB NVMe SSD          | $100    | 551GB free for testnet               |
| Solar setup & WiFi    | $0      | Already deployed, zero marginal cost |
| **Total**             | **$449** | No additional spending required      |

---

## Operating Costs

### Electricity

- Powered by solar panels
- Marginal cost = **$0/month**

### Internet

- Free WiFi (already paid)
- Marginal cost = **$0/month**

### Cooling

- Passive cooling / existing HVAC
- Marginal cost = **$0/month**

---

## Optional Costs (Future)

| Item                 | Monthly Cost | Notes                                  |
|----------------------|--------------|----------------------------------------|
| VPS Seed Node        | $5-8         | Hetzner or Contabo (optional)          |
| VPS Mining Node      | $12-24       | Only if moving mining to cloud         |
| Monitoring Service   | $0-20        | e.g., UptimeRobot, Grafana Cloud       |
| Domain Name          | $1-3         | Optional for easier access             |
| **Total (Optional)** | **$0-35**    | Only when upgrading to VPS             |

---

## Daily Tracking Template

```
Date: __________

Power Source: [Solar / Grid backup]
Battery Level: _____%
System Runtime: _____ hours
Downtime: _____ minutes

Notes:
- 
- 
- 
```

Store daily entries in `local-testnet/dashboard/reports/cost-tracking/`.

---

## Efficiency Tips

1. **CPU Scaling**: Use `./hashrate-simulator.sh` to reduce mining threads during off-hours.
2. **Night Operation**: If battery dips below 30%, reduce mining threads or pause mining.
3. **Storage Management**: Run `./reset-testnet.sh` monthly to prevent SSD wear.
4. **Docker Prune**: Weekly `docker system prune -af` to free space.
5. **Automation**: Add cron job to check battery state and auto-adjust mining.

---

## Upgrade Budget Plan

| Milestone                        | Cost | Trigger                                  |
|----------------------------------|------|------------------------------------------|
| Migrate 1 seed node to VPS       | $5   | After 30-day validation on local testnet |
| Migrate 2nd and 3rd seed to VPS  | $10  | After confirming first VPS stability      |
| Migrate mining node to VPS       | $20  | Optional, only if needed                 |

---

## Conclusion

The current setup runs entirely on existing hardware, solar power, and free internet, resulting in **$0/month** operating cost. Only upgrade to VPS when budget allows, using this document to plan ahead.

In this project, I have built a fully **automated infrastructure monitoring system** on **AWS**. 
It provisions everything from scratch, sets up **system monitoring**, **configures alerting rules**, and deploys a beautiful **dashboard to visualize** it all.

**Prerequisites**
- AWS account with IAM access
- SSH key pair uploaded to your EC2 region
- Terraform & Ansible installed on your local machine
- Replace the below given requirements as per requirement in terraform.tfvars:
    **ami_id
    key_name
    security_group_id**

**You will be able to:**
Monitor system health (like CPU, Memory, Disk, Network)
Receive alerts when thresholds are crossed
By using Grafana dashboards we can visualize metrics 
Automated everything with Terraform + Ansible

![image](https://github.com/user-attachments/assets/e91ab471-9420-42fa-90e9-8a80871faf5d)

**How to Deploy**
We’ve automated everything using Terraform + Ansible, so all you need to do is run:
**sh instance.sh**

**This script does the following:**
- Provisions an EC2 instance with Terraform
- Builds an inventory file using the public IP
- Runs an Ansible playbook to: Install Prometheus, Alertmanager, Node Exporter, and Grafana
- Configure all services
- Add a sample stress test to simulate load on the instance.

**Access the Tools**
Once setup is done, open these in your browser using the EC2 IP:

![image](https://github.com/user-attachments/assets/5ac3e27d-b629-44c9-a5b9-0ec5809ddd59)



To keep an eye on the performance of our servers (like EC2 instances, physical servers), we will be using Node Exporter.

Assume **Node Exporter** as a "sensor" running on our server. It will collect source metrics like:

- How much CPU is being used
- How much memory is being consumed
- How full the disk is
- How fast data is coming in and going out over the network


- After running **Node Exporter**, it exports the data to **Prometheus** which acts like a central data store. 
- **Prometheus** doesn't only store the data but it also validates the data at certain time-interval (e.g. every 15s) and checks if there's going to be any unusual.
- So, if your server’s **CPU usage** goes too high or **memory usage** gets out of hand, **Prometheus** can raise an alert based on the rules you set (like "CPU usage > 85% for 5 minutes").
- This is where **Alertmanager** comes in — it ensures you get notified (e.g., via **Slack**) if something goes wrong.
- Finally, to make sense of all this data, **Grafana** gives you beautiful dashboards where you can see the **metrics** visually. You can even track trends over time (e.g., CPU usage increasing throughout the day).
- In short, **Node Exporter** helps **Prometheus** understand what's happening inside your server, and **Grafana** helps you visualize it all. If things go wrong, **Alertmanager** makes sure you get a notification!

**Alerts Configured:**
- High CPU Usage
- Condition: >85% for 5 minutes
- Trigger command: **stress --cpu 1 --timeout 400**


**Scaling the Setup,**
**Need to monitor more servers? Just:**
- Add more instances via Terraform
- Point them to your Prometheus server
- Ansible playbooks are reusable, so setup is quick


**This setup gives you:**
- Real-time system monitoring
- Automatic alerts via Slack
- Full visibility with Grafana dashboards
- A repeatable and scalable solution via Infra-as-Code

    **🔔 If your server's having a bad day, you’ll know about it — before your users do..** 


- Feel free to fork, modify, and expand this setup for more production-grade observability — including container metrics, uptime monitoring, and log aggregation

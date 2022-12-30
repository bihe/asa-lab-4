using Microsoft.AspNetCore.SignalR;

namespace dashboard;

public interface INotificationClient
{
    Task ReceiveNotification(string hostName, string macAddr, DateTime timeStamp, string value);
}


public class NotificationHub : Hub<INotificationClient>
{
    public async Task SendNotification(string hostName, string macAddr, DateTime timeStamp, string value)
    {
        await Clients.All.ReceiveNotification(hostName, macAddr, timeStamp, value);
    }
}

using Microsoft.AspNetCore.SignalR;

namespace dashboard;

public interface INotificationClient
{
    Task ReceiveNotification(string macAddr, DateTime timeStamp, string value);
}


public class NotificationHub : Hub<INotificationClient>
{
    public async Task SendNotification(string macAddr, DateTime timeStamp, string value)
    {
        await Clients.All.ReceiveNotification(macAddr, timeStamp, value);
    }
}
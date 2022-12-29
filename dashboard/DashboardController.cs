using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace dashboard;

// dapr integration to pub-sub
// programmatically set the subscription to listen to
public record DaprSubscription(
    [property: JsonPropertyName("pubsubname")] string PubsubName,
    [property: JsonPropertyName("topic")] string Topic,
    [property: JsonPropertyName("route")] string Route
);

// Notification is the payload sent by the agent and received via the pub-sub-component
public class NotificationPayload
{
    [JsonPropertyName("host")]
    public string HostName { get; set; } = "";

    [JsonPropertyName("mac")]
    public string MacAddr { get; set; } = "";

    [JsonPropertyName("timestamp")]
    public string TimeStamp { get; set; } = "";

    [JsonPropertyName("value")]
    public string Value { get; set; } = "";
}

// dapr pub-sub data is wrapped into CloudEvents
// https://github.com/cloudevents/spec/tree/v1.0
public sealed class CloudEventMessage
{
    [JsonPropertyName("topic")]
    public string Topic { get; set; } = "";

    [JsonPropertyName("data")]
    public NotificationPayload Data { get; set; } = new NotificationPayload();
}

[ApiController]
public class DashBoardController : ControllerBase
{
    readonly IHubContext<NotificationHub, INotificationClient> _hub;

    const string DaprPubSubName = "pubsub";
    const string DaprPubSubTopic = "notifications";
    const string DaprPubSubRoute = "notifications";

    public DashBoardController(IHubContext<NotificationHub, INotificationClient> hub)
    {
        _hub = hub;
    }

    /// <summary>
    /// on startup of dapr and the dapr logic per app the route /dapr/subscribe is called
    /// this method returns the configuration logic for the pub-sub subscriber to notify dapr
    /// for which pub-sub-component and topic this logic is responsible. In addition a route is provided.
    /// This route is called by dapr to deliver pubsub messages to.
    /// </summary>
    /// <returns></returns>
    [HttpGet("/dapr/subscribe")]
    public List<DaprSubscription> SubScribeToDaprPubSub()
    {
        return new List<DaprSubscription> {
            new DaprSubscription(PubsubName: DaprPubSubName, Topic: DaprPubSubTopic, Route: DaprPubSubRoute)
        };
    }

    [HttpPost("/notifications")]
    public async Task<ActionResult> ReceivePubSubData([FromBody] CloudEventMessage ce)
    {
        var ts = DateTime.MinValue;
        ts = DateTime.Parse(ce.Data.TimeStamp);
        await _hub.Clients.All.ReceiveNotification(ce.Data.HostName, ce.Data.MacAddr, ts, ce.Data.Value);
        return Ok();
    }

    // ----------------------------------------------------------------------
    // debug and test -- define an endpoint which creates notification data and sends it to connected clients

    [HttpGet("/dashboard/random/{host}")]
    public async Task<ActionResult> SendRandomNotification(string host)
    {
        if(string.IsNullOrEmpty(host))
            host = "localhost";
        await _hub.Clients.All.ReceiveNotification(host, GetRandomString(16), DateTime.Now, "value");
        return Ok();
    }

    private static Random rnd = new Random();
    static string GetRandomString(int length)
    {
        var s = new String(Enumerable.Range(0, length).Select(n => (Char)(rnd.Next(32, 127))).ToArray());
        return s;
    }

    // ----------------------------------------------------------------------
}

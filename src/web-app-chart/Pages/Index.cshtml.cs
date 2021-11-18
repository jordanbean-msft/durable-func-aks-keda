using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading;
using System.Threading.Tasks;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using web_app_chart.Models.Chart;

namespace web_app_chart.Pages
{
  public class IndexModel : PageModel
  {
    public ChartJs QueueChart { get; set; }
    public string QueueChartJson { get; set; }

    private HttpClient httpClient;
    private readonly ILogger<IndexModel> _logger;
    public int QueueLength = 0;

    private Timer timer;

    private string StorageConnectionString = "DefaultEndpointsProtocol=https;AccountName=safuncakskedausscdemo;AccountKey=mRjYE+CoUk2mSnlCdaeFFqgifbAweTTb6cJ229tLMM/qUYpPHHXnF4OrPuM/DqCWrUfjNK6va8+reWLDzGRyJA==;EndpointSuffix=core.windows.net";

    private string AksHost = "http://localhost:8080";

    public IndexModel(ILogger<IndexModel> logger)
    {
      _logger = logger;
      httpClient = new HttpClient();
    }

    public async Task<ActionResult> OnGetQueueLengthAsync() {
      string[] labels = new string[1]{"# of Messages in Queue"};
      string[] counts = new string[1];

      var result = await GetQueueLength("input");
      counts[0] = result.ToString();

      return new JsonResult(new {
        labels = labels,
        counts = counts
      });
    }
    public async Task<ActionResult> OnGetPodCountAsync() {
      string[] labels = new string[1]{"# of Pods"};
      string[] pending = new string[1];
      string[] running = new string[1];
      string[] shuttingDown = new string[1];

      var result = await GetPodCount();
      pending[0] = result.Pending.ToString();
      running[0] = result.Running.ToString();
      shuttingDown[0] = result.ShuttingDown.ToString();

      return new JsonResult(new {
        labels = labels,
        pending = pending,
        running = running,
        shuttingDown = shuttingDown
      });
    }
 
    public async Task<ActionResult> OnGetNodePoolCountAsync() {
      string[] labels = new string[1]{"# of VMs in Node Pool"};
      string[] counts = new string[1];

      var result = await GetNodePoolCount();
      counts[0] = result.ToString();

      return new JsonResult(new {
        labels = labels,
        counts = counts
      });
    }
       
    public void OnGet() { }

  public async Task<PodStatusCount> GetPodCount()
  {
    var result = await httpClient.GetFromJsonAsync<KubernetesList>($"http://localhost:8080/api/v1/namespaces/compute/pods");
    PodStatusCount podStatusCount = new PodStatusCount{
      Pending = result.Items.Where(_ => _.Status.Phase == "Pending" || _.Status.Phase == "ContainerCreating").Count(),
      Running = result.Items.Where(_ => _.Status.Phase == "Running").Count(),
      ShuttingDown = result.Items.Where(_ => _.Status.Phase == "Terminating" || _.Status.Phase == "CrashLoopBackOff" || _.Status.Phase == "Error").Count()
    };
    return podStatusCount;
  }
  public async Task<int> GetNodePoolCount()
  {
    var result = await httpClient.GetFromJsonAsync<KubernetesList>($"http://localhost:8080/api/v1/nodes");
    return result.Items.Count();
  }

    public async Task<int> GetQueueLength(string queueName)
{
    // Get the connection string from app settings
    string connectionString = StorageConnectionString;

    // Instantiate a QueueClient which will be used to manipulate the queue
    QueueClient queueClient = new QueueClient(connectionString, queueName);

    if (queueClient.Exists())
    {
        QueueProperties properties = await queueClient.GetPropertiesAsync();

        // Retrieve the cached approximate message count.
        return properties.ApproximateMessagesCount;
    }

    throw new ArgumentException($"Unable to find storage queue with name ${queueName}");
}
  }

  public class PodStatusCount {
    public int Pending { get; set; }
    public int Running { get; set; }
    public int ShuttingDown { get; set; }
  }
public class ItemMetadata {
  public string Name { get; set; }
}
public class ItemStatus {
  public string Phase { get; set; }
}

  public class Item {
    public ItemMetadata Metadata { get; set; }
    public ItemStatus Status { get; set; }
  }

  public class KubernetesList
  {
    public string Kind { get; set; }
    public string ApiVersion { get; set; }
    public List<Item> Items { get; set; }
  }
}

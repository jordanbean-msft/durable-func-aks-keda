using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace web_app_chart.Pages
{
  public class IndexModel : PageModel
  {
    private HttpClient httpClient;
    private readonly ILogger<IndexModel> logger;
    private readonly IConfiguration configuration;
    private readonly string STORAGE_ACCOUNT_CONNECTION_STRING;

    private readonly string KUBECTL_PROXY_URI;

    private readonly string INPUT_CONTAINER_NAME;

    public IndexModel(ILogger<IndexModel> logger, IConfiguration configuration)
    {
      this.logger = logger;
      this.configuration = configuration;

      httpClient = new HttpClient();
      
      STORAGE_ACCOUNT_CONNECTION_STRING = configuration.GetConnectionString("StorageAccountConnectionString");
      KUBECTL_PROXY_URI = configuration["KubectlProxyUri"];
      INPUT_CONTAINER_NAME = configuration["InputContainerName"];
    }

    public async Task<ActionResult> OnGetQueueLengthAsync()
    {
      string[] counts = new string[1];

      var result = await GetQueueLength(INPUT_CONTAINER_NAME);
      counts[0] = result.ToString();

      return new JsonResult(new
      {
        counts = counts
      });
    }
    public async Task<ActionResult> OnGetPodCountAsync()
    {
      string[] pending = new string[1];
      string[] running = new string[1];

      var result = await GetPodCount();
      pending[0] = result.Pending.ToString();
      running[0] = result.Running.ToString();

      return new JsonResult(new
      {
        pending = pending,
        running = running,
      });
    }

    public async Task<ActionResult> OnGetNodePoolCountAsync()
    {
      string[] counts = new string[1];

      var result = await GetNodePoolCount();
      counts[0] = result.ToString();

      return new JsonResult(new
      {
        counts = counts
      });
    }

    public void OnGet() { }

    public async Task<PodStatusCount> GetPodCount()
    {
      var result = await httpClient.GetFromJsonAsync<KubernetesList>($"{KUBECTL_PROXY_URI}/api/v1/namespaces/compute/pods");
      PodStatusCount podStatusCount = new PodStatusCount
      {
        Pending = result.Items.Where(_ => _.Status.Phase == "Pending" || _.Status.Phase == "ContainerCreating").Count(),
        Running = result.Items.Where(_ => _.Status.Phase == "Running").Count(),
      };
      return podStatusCount;
    }
    public async Task<int> GetNodePoolCount()
    {
      var result = await httpClient.GetFromJsonAsync<KubernetesList>($"{KUBECTL_PROXY_URI}/api/v1/nodes");
      return result.Items.Count();
    }

    public async Task<int> GetQueueLength(string queueName)
    {
      string connectionString = STORAGE_ACCOUNT_CONNECTION_STRING;

      QueueClient queueClient = new QueueClient(connectionString, queueName);

      if (queueClient.Exists())
      {
        QueueProperties properties = await queueClient.GetPropertiesAsync();

        return properties.ApproximateMessagesCount;
      }

      throw new ArgumentException($"Unable to find storage queue with name ${queueName}");
    }
  }

  public class PodStatusCount
  {
    public int Pending { get; set; }
    public int Running { get; set; }
    public int ShuttingDown { get; set; }
  }
  public class ItemMetadata
  {
    public string Name { get; set; }
  }
  public class ItemStatus
  {
    public string Phase { get; set; }
  }

  public class Item
  {
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

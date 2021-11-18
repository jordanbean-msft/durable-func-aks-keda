#pragma checksum "C:\Users\jordanbean\source\repos\durable-func-aks-keda\src\web-app-chart\Pages\Index.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "d3c568f7f50e4c4a233c82e5e4ae5651159c0bb3"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(web_app_chart.Pages.Pages_Index), @"mvc.1.0.razor-page", @"/Pages/Index.cshtml")]
namespace web_app_chart.Pages
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.AspNetCore.Mvc.ViewFeatures;
#nullable restore
#line 1 "C:\Users\jordanbean\source\repos\durable-func-aks-keda\src\web-app-chart\Pages\_ViewImports.cshtml"
using web_app_chart;

#line default
#line hidden
#nullable disable
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"d3c568f7f50e4c4a233c82e5e4ae5651159c0bb3", @"/Pages/Index.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"c46344cd2f0178695a755b37dabdb3d8ae23ca52", @"/Pages/_ViewImports.cshtml")]
    public class Pages_Index : global::Microsoft.AspNetCore.Mvc.RazorPages.Page
    {
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
#nullable restore
#line 3 "C:\Users\jordanbean\source\repos\durable-func-aks-keda\src\web-app-chart\Pages\Index.cshtml"
  
  ViewData["Title"] = "Home page";

#line default
#line hidden
#nullable disable
            WriteLiteral(@"
<div style=""margin:0 auto; width: 100%;"">
<div class=""chart-container"" width=""34%"" style=""float:left;"">
  <canvas id=""queueChart""></canvas>
</div>
<div class=""chart-container"" width=""33%"" style=""float:left;"">
  <canvas id=""podChart""></canvas>
</div>
<div class=""chart-container"" width=""33%"" style=""float:left;"">
  <canvas id=""nodePoolChart""></canvas>
</div>
</div>

<script type=""text/javascript"">
  function GetQueueLengthJson() {
    var resp = [];
    $.ajax({
      type: ""GET"",
      url: '/?handler=QueueLength',
      async: false,
      contentType: ""application/json"",
      success: function (data) {
        resp.push(data);
      },
      error: function (req, status, error) {
        console.log(""error"");
        console.log(req);
        console.log(status);
        console.log(error);
      }
    });
    return resp;
  }
  function GetPodCountJson() {
    var resp = [];
    $.ajax({
      type: ""GET"",
      url: '/?handler=PodCount',
      async: false,
      con");
            WriteLiteral(@"tentType: ""application/json"",
      success: function (data) {
        resp.push(data);
      },
      error: function (req, status, error) {
        console.log(""error"");
        console.log(req);
        console.log(status);
        console.log(error);
      }
    });
    return resp;
  }
  function GetNodePoolCountJson() {
    var resp = [];
    $.ajax({
      type: ""GET"",
      url: '/?handler=NodePoolCount',
      async: false,
      contentType: ""application/json"",
      success: function (data) {
        resp.push(data);
      },
      error: function (req, status, error) {
        console.log(""error"");
        console.log(req);
        console.log(status);
        console.log(error);
      }
    });
    return resp;
  }

  document.addEventListener('DOMContentLoaded', (event) => {
    var queueLengthData = GetQueueLengthJson();
    var podCountData = GetPodCountJson();
    var nodePoolCountData = GetNodePoolCountJson();

    var queueCtx = document.getElementById(");
            WriteLiteral(@"'queueChart');
    var queueChart = new Chart(queueCtx,
      {
        type: 'bar',
        responsive: true,
        data:
        {
          labels: queueLengthData[0].labels,
          datasets: [{
            label: 'Count',
            data: queueLengthData[0].counts,
            backgroundColor: [
              'rgba(255, 99, 132, 0.2)',
            ],
            borderColor: [
              'rgba(255, 99, 132, 1)',
            ],
            borderWidth: 1
          }]
        },
        options:
        {
          scales:
          {
            yAxes: [{
              ticks:
              {
                beginAtZero: true
              }
            }]
          }
        }
      });
    var podCtx = document.getElementById('podChart');
    var podChart = new Chart(podCtx,
      {
        type: 'bar',
        responsive: true,
        data:
        {
          labels: podCountData[0].labels,
          datasets: [{
            label: 'Count',
          ");
            WriteLiteral(@"  data: podCountData[0].counts,
            backgroundColor: [
              'rgba(99, 255, 132, 0.2)',
            ],
            borderColor: [
              'rgba(99, 255, 132, 1)',
            ],
            borderWidth: 1
          }]
        },
        options:
        {
          scales:
          {
            yAxes: [{
              ticks:
              {
                beginAtZero: true
              }
            }]
          }
        }
      });
    var nodePoolCtx = document.getElementById('nodePoolChart');
    var nodePoolChart = new Chart(nodePoolCtx,
      {
        type: 'bar',
        responsive: true,
        data:
        {
          labels: nodePoolCountData[0].labels,
          datasets: [{
            label: 'Count',
            data: nodePoolCountData[0].counts,
            backgroundColor: [
              'rgba(99, 99, 255, 0.2)',
            ],
            borderColor: [
              'rgba(99, 99, 255, 1)',
            ],
            borderW");
            WriteLiteral(@"idth: 1
          }]
        },
        options:
        {
          scales:
          {
            yAxes: [{
              ticks:
              {
                beginAtZero: true
              }
            }]
          }
        }
      });

  setInterval(function() {
    var queueLengthData = GetQueueLengthJson();
    var podCountData = GetPodCountJson();
    var nodePoolCountData = GetNodePoolCountJson();
    
    queueChart.data.datasets[0].data[0] = queueLengthData[0].counts;
    podChart.data.datasets[0].data[0] = podCountData[0].counts;
    nodePoolChart.data.datasets[0].data[0] = nodePoolCountData[0].counts;
    
    queueChart.update();
    podChart.update();
    nodePoolChart.update();
  }, 5000)
  });
</script>");
        }
        #pragma warning restore 1998
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<IndexModel> Html { get; private set; }
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.ViewDataDictionary<IndexModel> ViewData => (global::Microsoft.AspNetCore.Mvc.ViewFeatures.ViewDataDictionary<IndexModel>)PageContext?.ViewData;
        public IndexModel Model => ViewData.Model;
    }
}
#pragma warning restore 1591

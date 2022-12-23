#include "simple_compute.h"
#include <chrono>
#include <random>

void CPU_Convo(int length) {
  std::vector<double> arr(length);
  std::mt19937 gen(322);
  std::uniform_real_distribution<double> dist(0, 1);
  for (size_t i = 0; i < length; i++)
  {
    arr[i] = dist(gen);
  }
  std::vector<double> conv(length);
  auto time_start = std::chrono::high_resolution_clock::now();
  for (size_t i = 0; i < length; i++)
  {
    double sum = 0.;
    for (int j = -3; j <= 3; j++)
    {
      int idx = i + j;
      if (idx >= 0 && idx < length)
      {
        sum += arr[idx];
      }
    }
    conv[i] = (arr[i] - sum / 7.);
  }

  auto time_end = std::chrono::high_resolution_clock::now();
  double avg = 0;
  for (auto v : conv)
  {
    avg += v;
  }
  avg /= length;
  std::cout << "Result (CPU): " << avg << '\n';
  std::cout << "Time (CPU): " << (time_end - time_start).count() / 1e6 << " msec";
}

int main()
{
  constexpr int LENGTH = 100;
  constexpr int VULKAN_DEVICE_ID = 0;

  std::shared_ptr<ICompute> app = std::make_unique<SimpleCompute>(LENGTH);
  if(app == nullptr)
  {
    std::cout << "Can't create render of specified type" << std::endl;
    return 1;
  }

  app->InitVulkan(nullptr, 0, VULKAN_DEVICE_ID);

  
  app->Execute();
  CPU_Convo(LENGTH);

  return 0;
}

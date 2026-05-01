using System.Diagnostics;
using System.Security.Principal;
using System.ServiceProcess;
using System.Text;

const string ServiceName = "dmicher-kripta-kards";
const string ServiceDisplayName = "Kripta Cards Web API Server";
const string ServiceDescription = "Сервер Web API модуля Карточки Крипты Foundry VTT. Автор dmicher abathur kubrow (c) 2026, Licensed under the Apache License 2.0.";
const string ServerExeName = "KriptaCardsWebServer.exe";

Console.OutputEncoding = Encoding.UTF8;
Console.InputEncoding = Encoding.UTF8;
Console.Title = "Установщик Kripta Cards";

while (true)
{
    DrawMenu();
    var command = Console.ReadLine()?.Trim();

    switch (command)
    {
        case "1":
            StartServerManually();
            Pause();
            break;

        case "2":
            InstallService();
            Pause();
            break;

        case "3":
            UninstallService();
            Pause();
            break;

        case "0":
            return;

        default:
            Console.WriteLine();
            WriteWarning("Неверная команда. Выберите команду из списка.");
            Pause();
            break;
    }
}

void DrawMenu()
{
    Console.Clear();

    var registered = IsServiceRegistered();
    var registrationStatus = registered ? "зарегистрирована" : "не зарегистрирована";
    var launchStatus = registered ? GetServiceLaunchStatus() : "не запущена";

    Console.WriteLine("dmicher abathur kubrow \\ Установщик Kripta Cards");
    Console.WriteLine($"Статус службы: {registrationStatus}, {launchStatus}");
    Console.WriteLine();
    Console.WriteLine("Выберите действие:");
    Console.WriteLine("    1 - запустить сервер;");
    Console.WriteLine("    2 - установить службу;");
    Console.WriteLine("    3 - удалить службу;");
    Console.WriteLine("    0 - выйти.");
    Console.WriteLine();
    Console.Write("Введите: ");
}

void StartServerManually()
{
    Console.WriteLine();

    if (IsServiceRegistered())
    {
        if (IsServiceRunning())
        {
            WriteInfo($"Программа уже зарегистрирована и запущена как служба {ServiceName}.");
        }
        else
        {
            WriteWarning($"Зарегистрирована служба {ServiceName}. Запустите её из меню Службы Windows, или удалите, выбрав пункт 3 меню.");
        }

        return;
    }

    var serverExePath = GetServerExePath();
    if (!File.Exists(serverExePath))
    {
        WriteError($"Не найден файл сервера: {serverExePath}");
        WriteInfo($"Положите эту утилиту рядом с {ServerExeName}.");
        return;
    }

    try
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = "cmd.exe",
            Arguments = $"/k \"\"{serverExePath}\"\"",
            WorkingDirectory = AppContext.BaseDirectory,
            UseShellExecute = true
        };

        Process.Start(startInfo);
        WriteOk("Сервер запущен в отдельном окне консоли.");
    }
    catch (Exception ex)
    {
        WriteError("Не удалось запустить сервер вручную.");
        Console.WriteLine(ex.Message);
    }
}

void InstallService()
{
    Console.WriteLine();

    if (IsServiceRegistered())
    {
        WriteWarning($"Служба {ServiceName} уже зарегистрирована.");
        return;
    }

    if (!IsAdministrator())
    {
        WriteError("Для установки службы запустите программу от имени администратора.");
        return;
    }

    var serverExePath = GetServerExePath();
    if (!File.Exists(serverExePath))
    {
        WriteError($"Не найден файл сервера: {serverExePath}");
        WriteInfo($"Положите эту утилиту рядом с {ServerExeName}.");
        return;
    }

    var createResult = RunSc(
        "create", ServiceName,
        "binPath=", $"\"{serverExePath}\"",
        "DisplayName=", ServiceDisplayName,
        "start=", "auto"
    );

    if (createResult.ExitCode != 0)
    {
        WriteError("Не удалось зарегистрировать службу.");
        PrintScResult(createResult);
        return;
    }

    RunSc("description", ServiceName, ServiceDescription);
    WriteOk($"Служба {ServiceName} зарегистрирована.");

    var startResult = RunSc("start", ServiceName);
    if (startResult.ExitCode == 0)
    {
        WriteOk($"Служба {ServiceName} запущена.");
        return;
    }

    WriteWarning($"Служба {ServiceName} зарегистрирована, но не была запущена.");
    WriteWarning("Стоит запустить приложение вручную через пункт 1 после удаления службы, либо напрямую из консоли, и посмотреть вывод с причинами ошибки.");
    PrintScResult(startResult);
}

void UninstallService()
{
    Console.WriteLine();

    if (!IsServiceRegistered())
    {
        WriteWarning($"Служба {ServiceName} не зарегистрирована.");
        return;
    }

    if (!IsAdministrator())
    {
        WriteError("Для удаления службы запустите программу от имени администратора.");
        return;
    }

    try
    {
        using var controller = new ServiceController(ServiceName);

        if (controller.Status is ServiceControllerStatus.Running or ServiceControllerStatus.StartPending or ServiceControllerStatus.Paused)
        {
            WriteInfo($"Останавливаю службу {ServiceName}...");
            controller.Stop();
            controller.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromSeconds(20));
            WriteOk("Служба остановлена.");
        }
    }
    catch (Exception ex)
    {
        WriteWarning("Не удалось штатно остановить службу. Попробую удалить регистрацию.");
        Console.WriteLine(ex.Message);
    }

    var deleteResult = RunSc("delete", ServiceName);
    if (deleteResult.ExitCode == 0)
    {
        WriteOk($"Регистрация службы {ServiceName} удалена.");
    }
    else
    {
        WriteError("Не удалось удалить регистрацию службы.");
        PrintScResult(deleteResult);
    }
}

bool IsServiceRegistered()
{
    try
    {
        using var controller = new ServiceController(ServiceName);
        _ = controller.Status;
        return true;
    }
    catch
    {
        return false;
    }
}

bool IsServiceRunning()
{
    try
    {
        using var controller = new ServiceController(ServiceName);
        return controller.Status == ServiceControllerStatus.Running;
    }
    catch
    {
        return false;
    }
}

string GetServiceLaunchStatus()
{
    try
    {
        using var controller = new ServiceController(ServiceName);
        return controller.Status switch
        {
            ServiceControllerStatus.Running => "запущена",
            ServiceControllerStatus.Stopped => "не запущена",
            ServiceControllerStatus.Paused => "приостановлена",
            ServiceControllerStatus.StartPending => "запускается",
            ServiceControllerStatus.StopPending => "останавливается",
            ServiceControllerStatus.ContinuePending => "возобновляется",
            ServiceControllerStatus.PausePending => "приостанавливается",
            _ => controller.Status.ToString()
        };
    }
    catch
    {
        return "статус неизвестен";
    }
}

string GetServerExePath()
{
    return Path.Combine(AppContext.BaseDirectory, ServerExeName);
}

bool IsAdministrator()
{
    using var identity = WindowsIdentity.GetCurrent();
    var principal = new WindowsPrincipal(identity);
    return principal.IsInRole(WindowsBuiltInRole.Administrator);
}

ScResult RunSc(params string[] args)
{
    using var process = new Process();
    process.StartInfo.FileName = "sc.exe";
    process.StartInfo.UseShellExecute = false;
    process.StartInfo.RedirectStandardOutput = true;
    process.StartInfo.RedirectStandardError = true;
    process.StartInfo.StandardOutputEncoding = Encoding.UTF8;
    process.StartInfo.StandardErrorEncoding = Encoding.UTF8;

    foreach (var arg in args)
    {
        process.StartInfo.ArgumentList.Add(arg);
    }

    process.Start();
    var output = process.StandardOutput.ReadToEnd();
    var error = process.StandardError.ReadToEnd();
    process.WaitForExit();

    return new ScResult(process.ExitCode, output, error);
}

void PrintScResult(ScResult result)
{
    if (!string.IsNullOrWhiteSpace(result.Output))
    {
        Console.WriteLine(result.Output.Trim());
    }

    if (!string.IsNullOrWhiteSpace(result.Error))
    {
        Console.WriteLine(result.Error.Trim());
    }
}

void Pause()
{
    Console.WriteLine();
    Console.Write("Нажмите Enter, чтобы вернуться в меню...");
    Console.ReadLine();
}

void WriteOk(string message)
{
    WriteColored("[OK] ", ConsoleColor.Green);
    Console.WriteLine(message);
}

void WriteInfo(string message)
{
    WriteColored("[INFO] ", ConsoleColor.Cyan);
    Console.WriteLine(message);
}

void WriteWarning(string message)
{
    WriteColored("[WARN] ", ConsoleColor.Yellow);
    Console.WriteLine(message);
}

void WriteError(string message)
{
    WriteColored("[ERROR] ", ConsoleColor.Red);
    Console.WriteLine(message);
}

void WriteColored(string text, ConsoleColor color)
{
    var oldColor = Console.ForegroundColor;
    Console.ForegroundColor = color;
    Console.Write(text);
    Console.ForegroundColor = oldColor;
}

record ScResult(int ExitCode, string Output, string Error);

#include "MyForm.h"

using namespace System;
using namespace System::Windows::Forms;

namespace invgui {
    int __clrcall WinMain(array<System::String^>^ args) {
        Application::EnableVisualStyles();
        Application::SetCompatibleTextRenderingDefault(false);

        Application::Run(gcnew MyForm());
        return 0;
    }
}

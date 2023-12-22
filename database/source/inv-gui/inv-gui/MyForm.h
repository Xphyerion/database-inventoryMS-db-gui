#pragma once

#include <cppconn/driver.h>
#include <cppconn/exception.h>
#include <cppconn/statement.h>
#include <iostream>
#include <mysql_connection.h>
#include <mysql_driver.h>

namespace invgui {

    using namespace System;
    using namespace System::ComponentModel;
    using namespace System::Windows::Forms;
    using namespace System::Data;
    using namespace System::Drawing;

    public ref class MyForm : public System::Windows::Forms::Form
    {
    private:
        System::ComponentModel::Container^ components;

    public:
        MyForm(void)
        {
            InitializeComponent();
        }

    protected:
        ~MyForm()
        {
            if (components)
            {
                delete components;
            }
        }

    private: System::Windows::Forms::Button^ button3;
    private: System::Windows::Forms::Button^ button4;
    private: System::Windows::Forms::Label^ label2;
    private: System::Windows::Forms::Label^ label1;

    private:
        sql::Connection* con;

#pragma region Windows Form Designer generated code
        void InitializeComponent(void)
        {
            System::ComponentModel::ComponentResourceManager^ resources = (gcnew System::ComponentModel::ComponentResourceManager(MyForm::typeid));
            this->button3 = (gcnew System::Windows::Forms::Button());
            this->button4 = (gcnew System::Windows::Forms::Button());
            this->label2 = (gcnew System::Windows::Forms::Label());
            this->label1 = (gcnew System::Windows::Forms::Label());
            this->SuspendLayout();
           
            this->button3->BackColor = System::Drawing::Color::Lime;
            this->button3->Font = (gcnew System::Drawing::Font(L"Perpetua Titling MT", 20.25F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
                static_cast<System::Byte>(0)));
            this->button3->Location = System::Drawing::Point(102, 77);
            this->button3->Name = L"button3";
            this->button3->Size = System::Drawing::Size(211, 70);
            this->button3->TabIndex = 0;
            this->button3->Text = L"connect";
            this->button3->UseVisualStyleBackColor = false;
            this->button3->Click += gcnew System::EventHandler(this, &MyForm::button3_Click);
          
            this->button4->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(255)), static_cast<System::Int32>(static_cast<System::Byte>(128)),
                static_cast<System::Int32>(static_cast<System::Byte>(128)));
            this->button4->Font = (gcnew System::Drawing::Font(L"Perpetua Titling MT", 20.25F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
                static_cast<System::Byte>(0)));
            this->button4->Location = System::Drawing::Point(378, 77);
            this->button4->Name = L"button4";
            this->button4->Size = System::Drawing::Size(211, 70);
            this->button4->TabIndex = 1;
            this->button4->Text = L"disconnect";
            this->button4->UseVisualStyleBackColor = false;
            this->button4->Click += gcnew System::EventHandler(this, &MyForm::button4_Click);
             
            this->label2->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(192)), static_cast<System::Int32>(static_cast<System::Byte>(255)),
                static_cast<System::Int32>(static_cast<System::Byte>(255)));
            this->label2->BorderStyle = System::Windows::Forms::BorderStyle::Fixed3D;
            this->label2->Font = (gcnew System::Drawing::Font(L"Arial", 14, System::Drawing::FontStyle::Bold));
            this->label2->ForeColor = System::Drawing::SystemColors::ControlText;
            this->label2->Location = System::Drawing::Point(191, 191);
            this->label2->Name = L"label2";
            this->label2->Size = System::Drawing::Size(282, 50);
            this->label2->TabIndex = 2;
            this->label2->Text = L"status: not connected";
            this->label2->TextAlign = System::Drawing::ContentAlignment::MiddleCenter;
            this->label2->Click += gcnew System::EventHandler(this, &MyForm::label2_Click);
            
            this->label1->BackColor = System::Drawing::Color::Black;
            this->label1->BorderStyle = System::Windows::Forms::BorderStyle::Fixed3D;
            this->label1->Font = (gcnew System::Drawing::Font(L"Arial", 16, System::Drawing::FontStyle::Bold));
            this->label1->ForeColor = System::Drawing::SystemColors::Control;
            this->label1->Location = System::Drawing::Point(190, 280);
            this->label1->Name = L"label1";
            this->label1->Size = System::Drawing::Size(283, 50);
            this->label1->TabIndex = 3;
            this->label1->Text = L"DB STANDBY";
            this->label1->TextAlign = System::Drawing::ContentAlignment::MiddleCenter;
            this->label1->Click += gcnew System::EventHandler(this, &MyForm::label1_Click);
            
            this->BackColor = System::Drawing::Color::DarkSlateGray;
            this->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"$this.BackgroundImage")));
            this->BackgroundImageLayout = System::Windows::Forms::ImageLayout::Stretch;
            this->ClientSize = System::Drawing::Size(675, 373);
            this->Controls->Add(this->label1);
            this->Controls->Add(this->label2);
            this->Controls->Add(this->button4);
            this->Controls->Add(this->button3);
            this->Font = (gcnew System::Drawing::Font(L"Copperplate Gothic Light", 21.75F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
                static_cast<System::Byte>(0)));
            this->FormBorderStyle = System::Windows::Forms::FormBorderStyle::FixedSingle;
            this->Icon = (cli::safe_cast<System::Drawing::Icon^>(resources->GetObject(L"$this.Icon")));
            this->Name = L"MyForm";
            this->Text = L"Inventory Management Database Connector";
            this->Load += gcnew System::EventHandler(this, &MyForm::MyForm_Load);
            this->ResumeLayout(false);

        }
#pragma endregion

    private: System::Void button3_Click(System::Object^ sender, System::EventArgs^ e) {
        try {
            sql::mysql::MySQL_Driver* driver;
            driver = sql::mysql::get_mysql_driver_instance();
            con = driver->connect("tcp://localhost:3306", "root", "");
            con->setSchema("inv_mgmt_db");

           
            std::string dbName = con->getSchema();
            String^ managedDbName = gcnew String(dbName.c_str());

            label2->Text = "Status: Connected";
            label1->Text = "Database: " + managedDbName;
        }
        catch (sql::SQLException& ex) {
            std::cerr << "SQL Connection Error: " << ex.what() << std::endl;
            label2->Text = "Status: Connection Failed";
            label1->Text = "DB STANDBY";

           
            MessageBox::Show("Failed to connect to the database.\nError: " + gcnew String(ex.what()), "Connection Error", MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }

    private: System::Void button4_Click(System::Object^ sender, System::EventArgs^ e) {
        try {
            if (con) {
                delete con;
                con = nullptr; 
                label2->Text = "Status: Disconnected";
                label1->Text = "DB STANDBY";
            }
            else {
                
                MessageBox::Show("Not connected to the database.", "Disconnection Warning", MessageBoxButtons::OK, MessageBoxIcon::Warning);
            }
        }
        catch (sql::SQLException& ex) {
            std::cerr << "SQL Disconnection Error: " << ex.what() << std::endl;
            label2->Text = "Status: Disconnection Failed";
            label1->Text = "DB STANDBY";
        }
    }
    private: System::Void label2_Click(System::Object^ sender, System::EventArgs^ e) {
    }
    private: System::Void label1_Click(System::Object^ sender, System::EventArgs^ e) {
    }
    private: System::Void MyForm_Load(System::Object^ sender, System::EventArgs^ e) {
    }
};
}

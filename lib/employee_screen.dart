import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'employee.dart';


class EmployeeScreen extends StatefulWidget {
  EmployeeScreen({Key? key}) : super(key: key);

  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  Future<List<EmployeeModel>>? employeeListFuture;

  List<EmployeeModel> emp = <EmployeeModel>[];
  List<EmployeeModel> filteredEmp = <EmployeeModel>[];
  late EmployeeDataSource employeeDataSource;

  String? selectedGender;
  String? selectedCountry;
  List<String> genderList = [];
  List<String> countryList = [];

  int currentPage = 0;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    employeeListFuture = fetchEmployees();
  }

  Future<List<EmployeeModel>> fetchEmployees() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/users'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> usersJson = data['users'];
      emp = usersJson.map((json) => EmployeeModel.fromJson(json)).toList();
      filteredEmp = emp;
      updateDataSource();

      // Extract unique gender and country values for the dropdowns
      genderList = emp.map((e) => e.gender!).toSet().toList();
      countryList = emp.map((e) {
        return e.address!.country!;
      }).toSet().toList();

      return emp;
    } else {
      throw Exception('Failed to load employees');
    }
  }

  void updateDataSource() {
    final pagedData =
    filteredEmp.skip(currentPage * pageSize).take(pageSize).toList();
    employeeDataSource = EmployeeDataSource(employeeData: pagedData);
  }

  void filterEmployees() {
    setState(() {
      filteredEmp = emp.where((e) {
        final matchesGender = selectedGender == null ||
            selectedGender!.isEmpty ||
            e.gender == selectedGender;
        final matchesCountry = selectedCountry == null ||
            selectedCountry!.isEmpty ||
            e.address!.country == selectedCountry;
        return matchesGender && matchesCountry;
      }).toList();
      updateDataSource();
    });
  }

  void goToNextPage() {
    setState(() {
      if ((currentPage + 1) * pageSize < filteredEmp.length) {
        currentPage++;
        updateDataSource();
      }
    });
  }

  void goToPreviousPage() {
    setState(() {
      if (currentPage > 0) {
        currentPage--;
        updateDataSource();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/Pixel6.png",
            color: Colors.red,
          ),
        ),
        actions: const [Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.format_align_justify),
        )],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // height: MediaQuery.of(context).size.height/1.2,
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: FutureBuilder<List<EmployeeModel>>(
            future: employeeListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No employees found'));
              } else {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Employees",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.filter_alt,color: Colors.red,),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              height: 50,
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCountry,
                                hint: const Text(
                                  'Country',
                                  style: TextStyle(fontSize: 13),
                                ),
                                icon: const Icon(Icons.arrow_drop_down,color: Colors.red,),
                                iconSize: 24,
                                elevation: 16,
                                underline:
                                const SizedBox(), // Removes default underline
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCountry = newValue;
                                    filterEmployees();
                                  });
                                },
                                items:
                                countryList.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              height: 50,
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedGender,
                                hint: const Text(
                                  'Gender',
                                  style: TextStyle(fontSize: 13),
                                ),
                                icon: const Icon(Icons.arrow_drop_down,color: Colors.red,),
                                iconSize: 24,
                                elevation: 16,
                                underline:
                                const SizedBox(), // Removes default underline
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedGender = newValue;
                                    filterEmployees();
                                  });
                                },
                                items: genderList.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // DataGrid
                    const SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: SfDataGrid(
                        allowSorting: true,
                        allowMultiColumnSorting: true,
                        source: employeeDataSource,
                        columns: [
                          GridColumn(
                            width: 82,
                            columnName: 'id',
                            allowSorting: true,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('ID'),
                            ),
                          ),
                          GridColumn(
                            width: 75,
                            columnName: 'image',
                            allowSorting: false,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Image'),
                            ),
                          ),
                          GridColumn(
                            width: 200,
                            columnName: 'fullName',
                            allowSorting: true,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Full Name'),
                            ),
                          ),
                          GridColumn(
                            width: 150,
                            columnName: 'demography',
                            allowSorting: true,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Demography'),
                            ),
                          ),
                          GridColumn(
                            width: 150,
                            columnName: 'designation',
                            allowSorting: false,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Designation'),
                            ),
                          ),
                          GridColumn(
                            width: 200,
                            columnName: 'location',
                            allowSorting: false,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Location'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pagination Controls
                    Align(alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: goToPreviousPage,
                                icon: const Icon(Icons.arrow_back_ios)),
                            Text("$currentPage"),
                            IconButton(
                                onPressed: goToNextPage,
                                icon: const Icon(Icons.arrow_forward_ios)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource({required List<EmployeeModel> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'id', value: e.id),
      DataGridCell<String>(columnName: 'image', value: e.image),
      DataGridCell<String>(
          columnName: 'fullName',
          value: '${e.firstName} ${e.lastName}'),
      DataGridCell<String>(
          columnName: 'demography',
          value: '${e.gender![0].toUpperCase()}/${e.age}'),
      DataGridCell<String>(
          columnName: 'designation',
          value: '${e.company!.title.toString()} '),
      DataGridCell<String>(
          columnName: 'location',
          value:
          '${e.address!.state.toString()}, ${e.address!.country.toString()}'),
    ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'image') {
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: CircleAvatar(child: Image.network(dataGridCell.value)),
            // child: Image.network(dataGridCell.value),
          );
        } else if (dataGridCell.columnName == 'id') {
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(
              dataGridCell.value.toString(),
              style: const TextStyle(color: Colors.black),
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              dataGridCell.value.toString(),
              style: const TextStyle(color: Colors.black),
            ),
          );
        }
      }).toList(),
    );
  }
}
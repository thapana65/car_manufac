import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:car_manufac/car_mfr.dart'; // เชื่อมต่อกับไฟล์ car_mfr.dart

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  List<Result> manufacturers = []; // เก็บข้อมูลผู้ผลิต
  List<Result> filteredManufacturers = []; // เก็บข้อมูลที่ผ่านการกรอง

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<CarMfr> getCarMfr() async {
    var url = 'vpic.nhtsa.dot.gov';
    var uri = Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    var response = await get(uri);

    CarMfr carMfr = carMfrFromJson(response.body);
    manufacturers = carMfr.results!; // เก็บข้อมูลผู้ผลิตในตัวแปร
    filteredManufacturers = manufacturers; // เริ่มต้นแสดงทั้งหมด
    return carMfr;
  }

  // ฟังก์ชันค้นหาผู้ผลิต
  void filterManufacturers(String query) {
    setState(() {
      filteredManufacturers = manufacturers
          .where((manufacturer) {
            var lowerQuery = query.toLowerCase();
            // ตรวจสอบให้แน่ใจว่าไม่ใช่ null ก่อนทำการค้นหา
            return (manufacturer.mfrCommonName?.toLowerCase().contains(lowerQuery) ?? false) ||
                (manufacturer.mfrName?.toLowerCase().contains(lowerQuery) ?? false) ||
                (manufacturer.country?.toLowerCase().contains(lowerQuery) ?? false);
          })
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getCarMfr(); // เรียกใช้ฟังก์ชันดึงข้อมูล
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: filterManufacturers, // ฟังก์ชันค้นหาจะถูกเรียกเมื่อพิมพ์ข้อความ
              decoration: InputDecoration(
                labelText: "Search Manufacturer",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<CarMfr>(
              future: getCarMfr(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red)));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: filteredManufacturers.length,
                    itemBuilder: (context, index) {
                      var manufacturer = filteredManufacturers[index];
                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          leading: Icon(Icons.directions_car,
                              color: Colors.blueGrey),
                          title: Text(
                            manufacturer.mfrCommonName ?? "No Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.blueGrey,
                            ),
                          ),
                          subtitle: Text(
                            "ID: ${manufacturer.mfrId}",
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                            ),
                          ),
                          onTap: () {
                            // เปิดหน้าจอรายละเอียด
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetailsPage(manufacturer),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text('No data found',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CarDetailsPage extends StatelessWidget {
  final Result manufacturer;

  CarDetailsPage(this.manufacturer);

  // ฟังก์ชันเพื่อแปลงค่า Enum หรือค่าคงที่เป็นข้อความที่เข้าใจง่าย
  String getVehicleTypeName(String vehicleType) {
    Map<String, String> vehicleTypeMap = {
      'PASSENGER_CAR': 'Passenger Car',
      'TRUCK': 'Truck',
      'SUV': 'SUV',
      // เพิ่มประเภทอื่น ๆ ที่ต้องการ
    };

    return vehicleTypeMap[vehicleType] ?? vehicleType;
  }

  @override
  Widget build(BuildContext context) {
    var vehicleTypes = manufacturer.vehicleTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text('${manufacturer.mfrCommonName} Details'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manufacturer: ${manufacturer.mfrName}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Country: ${manufacturer.country}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Text(
              'Vehicle Types:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // แสดงประเภทของรถยนต์
            ...(vehicleTypes?.isNotEmpty ?? false)
                ? vehicleTypes!.map<Widget>((vehicle) {
                    return Row(
                      children: [
                        Icon(
                          vehicle.isPrimary! ? Icons.check_circle : Icons.cancel,
                          color: vehicle.isPrimary! ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 10),
                        // แสดงประเภทของรถยนต์ในรูปแบบที่เข้าใจง่าย
                        Text(
                          getVehicleTypeName(vehicle.name?.toString() ?? "Unknown"),
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    );
                  }).toList()
                : [],
          ],
        ),
      ),
    );
  }
}

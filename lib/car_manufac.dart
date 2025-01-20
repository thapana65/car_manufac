import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:car_manufac/car_mfr.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  Future<CarMfr> getCarMfr() async {
    var url = 'vpic.nhtsa.dot.gov';

    var uri =
        Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    // https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json
    await Future.delayed(const Duration(seconds: 3));
    var response = await get(uri);

    CarMfr carMfr = carMfrFromJson(response.body);
    print(carMfr.results![0].mfrName);
    return carMfr;
  }

  @override
  void initState() {
    super.initState();
    getCarMfr();
    print('Initiated...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder<CarMfr>(
        future: getCarMfr(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var manufacturers = snapshot.data!.results!;
            return ListView.builder(
              itemCount: manufacturers.length,
              itemBuilder: (context, index) {
                var manufacturer = manufacturers[index];
                return ListTile(
                  title: Text(manufacturer.mfrName ?? "No Name"),
                  subtitle: Text("ID: ${manufacturer.mfrId}"),
                );
              },
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:cache_dio/employees.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dio and Cache')),
      body: FutureBuilder(
        future: EmployeesController.getAllEmployees(),
        builder: (BuildContext context, AsyncSnapshot<List<Data>?> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: Colors.blueGrey,
                      child: ListTile(
                        title: Text(snapshot.data![index].employeeName!),
                        subtitle: Text(
                            snapshot.data![index].employeeSalary.toString()),
                        trailing:
                            Text(snapshot.data![index].employeeAge.toString()),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text('No Data Found'));
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class EmployeesController {
  static Future<List<Data>?> getAllEmployees() async {
    String url = 'http://dummy.restapiexample.com/api/v1/employees';
    List<Data> result = [];
    try {
      Dio dio = Dio();
      DioCacheManager dioCacheManager = DioCacheManager(CacheConfig());
      Options myOptions =
          buildCacheOptions(const Duration(days: 30), forceRefresh: true);
      dio.interceptors.add(dioCacheManager.interceptor);

      var res = await dio.get(url, options: myOptions);
      result = getList(res.data);
    } catch (e) {
      if (e is SocketException) {
        return null;
      }
    }
    return result;
  }

  static getList(body) {
    List<Data> emp = [];
    List x = (body)['data'];
    x.forEach((element) {
      emp.add(Data.fromJson(element));
    });

    return emp;
  }
}

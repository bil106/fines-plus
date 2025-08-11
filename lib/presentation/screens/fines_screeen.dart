import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
@RoutePage()
class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {


  @override
  Widget build(BuildContext context) {
    return  
    AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle.dark,
  child:
    Container(
      color: Colors.grey.shade50,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                child: const Text(
                  'LOGO',
                  style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
      
          
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {},
                  child: const Text('Перевірити штрафи', style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
      
              
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                   const SizedBox(width: 20),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text('На вас немає штрафів', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        
      
        
     
      ),
    ));
  }
}

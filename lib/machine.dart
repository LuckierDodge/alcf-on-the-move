import 'package:flutter/material.dart';

class Machine extends StatefulWidget {
  final String name;
  Machine(this.name);
  @override
  MachineState createState() => MachineState(name);
}

class MachineState extends State<Machine> {
  final String name;
  MachineState(this.name);
  @override
  Widget build(BuildContext context) {
    
  }
}
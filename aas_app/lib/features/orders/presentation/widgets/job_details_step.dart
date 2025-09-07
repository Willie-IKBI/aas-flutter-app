import 'package:flutter/material.dart';

class JobDetailsStep extends StatelessWidget {
  const JobDetailsStep({
    super.key,
    this.equipmentType,
    this.equipmentModel,
    this.equipmentSerialNumber,
    required this.jobDescription,
    required this.orderDate,
    required this.onEquipmentTypeChanged,
    required this.onEquipmentModelChanged,
    required this.onEquipmentSerialNumberChanged,
    required this.onJobDescriptionChanged,
    required this.onOrderDateChanged,
  });
  final String? equipmentType;
  final String? equipmentModel;
  final String? equipmentSerialNumber;
  final String jobDescription;
  final DateTime orderDate;
  final Function(String?) onEquipmentTypeChanged;
  final Function(String?) onEquipmentModelChanged;
  final Function(String?) onEquipmentSerialNumberChanged;
  final Function(String) onJobDescriptionChanged;
  final Function(DateTime) onOrderDateChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Job Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter equipment details and job description',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Date
                  Text(
                    'Order Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: orderDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        onOrderDateChanged(date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Equipment Information
                  Text(
                    'Equipment Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provide details about the equipment being serviced',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Equipment Type
                  TextFormField(
                    initialValue: equipmentType,
                    decoration: const InputDecoration(
                      labelText: 'Equipment Type',
                      hintText: 'e.g., Excavator, Bulldozer, Pump',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.build),
                    ),
                    onChanged: onEquipmentTypeChanged,
                  ),
                  const SizedBox(height: 16),

                  // Equipment Model
                  TextFormField(
                    initialValue: equipmentModel,
                    decoration: const InputDecoration(
                      labelText: 'Equipment Model',
                      hintText: 'e.g., PC200-7, D8R',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.model_training),
                    ),
                    onChanged: onEquipmentModelChanged,
                  ),
                  const SizedBox(height: 16),

                  // Equipment Serial Number
                  TextFormField(
                    initialValue: equipmentSerialNumber,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number (Optional)',
                      hintText: 'Equipment serial number if available',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    onChanged: onEquipmentSerialNumberChanged,
                  ),
                  const SizedBox(height: 24),

                  // Job Description
                  Text(
                    'Job Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe the work to be performed',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: jobDescription,
                    decoration: const InputDecoration(
                      labelText: 'Job Description *',
                      hintText:
                          'Describe the work, repairs, or services needed...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    onChanged: onJobDescriptionChanged,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Job description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Help text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Be as detailed as possible in your job description. Include specific issues, parts needed, or special requirements.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

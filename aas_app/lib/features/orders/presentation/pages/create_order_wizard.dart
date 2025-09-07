import 'package:flutter/material.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/customer_selection_step.dart';
import '../widgets/job_details_step.dart';
import '../widgets/equipment_photos_step.dart';
import '../widgets/sales_rep_step.dart';
import '../widgets/review_step.dart';

class CreateOrderWizard extends StatefulWidget {
  const CreateOrderWizard({super.key});

  @override
  State<CreateOrderWizard> createState() => _CreateOrderWizardState();
}

class _CreateOrderWizardState extends State<CreateOrderWizard>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Wizard data
  Customer? _selectedCustomer;
  String? _equipmentType;
  String? _equipmentModel;
  String? _equipmentSerialNumber;
  String _jobDescription = '';
  List<dynamic> _photos = []; // Can be File or PlatformFile
  UserProfile? _selectedSalesRep;
  DateTime _orderDate = DateTime.now();

  final List<String> _stepTitles = [
    'Customer',
    'Job Details',
    'Equipment Photos',
    'Sales Rep',
    'Review',
  ];

  final List<IconData> _stepIcons = [
    Icons.people,
    Icons.work,
    Icons.camera_alt,
    Icons.person_pin,
    Icons.check_circle,
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _stepTitles.length);
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _updateProgress();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _updateProgress();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _updateProgress();
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedCustomer != null;
      case 1:
        return _jobDescription.isNotEmpty;
      case 2:
        return true; // Photos step - optional
      case 3:
        return _selectedSalesRep != null;
      case 4:
        return true; // Review step
      default:
        return false;
    }
  }

  Future<void> _createOrder() async {
    if (_selectedCustomer == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final order = await OrderService.createOrder(
        orderDate: _orderDate,
        description: _jobDescription,
        customerId: _selectedCustomer!.id,
        salesRepId: _selectedSalesRep?.id,
        equipmentType: _equipmentType,
        equipmentModel: _equipmentModel,
        equipmentSerialNumber: _equipmentSerialNumber,
      );

      if (order != null) {
        // Upload photos if any
        if (_photos.isNotEmpty) {
          for (final photo in _photos) {
            await PhotoService.uploadOrderPhoto(
              orderId: order.id,
              photoFile: photo,
              photoName: 'Equipment Photo',
              photoDescription: 'Photo taken during order creation',
            );
          }
        }

        // Show success notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Order #${order.id} created successfully!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navigate back to dashboard
          Navigator.of(context).pop(order);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to create order. Please try again.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // Back Button
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.glassGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.onSurface,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create New Order',
                                style: TextStyle(
                                  fontSize: isDesktop ? 28 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Step ${_currentStep + 1} of ${_stepTitles.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Step Progress (Desktop)
                        if (isDesktop) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timeline,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_currentStep + 1}/${_stepTitles.length}',
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress Steps
                    Row(
                      children: List.generate(_stepTitles.length, (index) {
                        final isActive = index == _currentStep;
                        final isCompleted = index < _currentStep;
                        final isAccessible =
                            index <= _currentStep || isCompleted;

                        return Expanded(
                          child: GestureDetector(
                            onTap: isAccessible ? () => _goToStep(index) : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  // Step Circle
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: isDesktop ? 56 : 48,
                                    height: isDesktop ? 56 : 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isCompleted
                                          ? AppColors.successGradient
                                          : isActive
                                              ? AppColors.primaryGradient
                                              : AppColors.glassGradient,
                                      border: Border.all(
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.outline
                                                .withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: isCompleted
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: isDesktop ? 24 : 20,
                                            )
                                          : Icon(
                                              _stepIcons[index],
                                              color: isActive
                                                  ? Colors.white
                                                  : AppColors.onSurfaceVariant,
                                              size: isDesktop ? 24 : 20,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Step Title
                                  Text(
                                    _stepTitles[index],
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 12,
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isActive
                                          ? AppColors.primary
                                          : isCompleted
                                              ? AppColors.success
                                              : AppColors.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Progress Bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.surfaceVariant,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(isDesktop ? 24 : 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Step 1: Customer Selection
                        CustomerSelectionStep(
                          selectedCustomer: _selectedCustomer,
                          onCustomerSelected: (customer) {
                            setState(() {
                              _selectedCustomer = customer;
                            });
                          },
                          onNewCustomerCreated: (customer) {
                            setState(() {
                              _selectedCustomer = customer;
                            });
                          },
                        ),

                        // Step 2: Job Details
                        JobDetailsStep(
                          equipmentType: _equipmentType,
                          equipmentModel: _equipmentModel,
                          equipmentSerialNumber: _equipmentSerialNumber,
                          jobDescription: _jobDescription,
                          orderDate: _orderDate,
                          onEquipmentTypeChanged: (value) {
                            setState(() {
                              _equipmentType = value;
                            });
                          },
                          onEquipmentModelChanged: (value) {
                            setState(() {
                              _equipmentModel = value;
                            });
                          },
                          onEquipmentSerialNumberChanged: (value) {
                            setState(() {
                              _equipmentSerialNumber = value;
                            });
                          },
                          onJobDescriptionChanged: (value) {
                            setState(() {
                              _jobDescription = value;
                            });
                          },
                          onOrderDateChanged: (date) {
                            setState(() {
                              _orderDate = date;
                            });
                          },
                        ),

                        // Step 3: Equipment Photos
                        EquipmentPhotosStep(
                          photos: _photos,
                          onPhotosChanged: (photos) {
                            setState(() {
                              _photos = photos;
                            });
                          },
                          onNext: _nextStep,
                          onPrevious: _previousStep,
                        ),

                        // Step 4: Sales Representative
                        SalesRepStep(
                          selectedSalesRep: _selectedSalesRep,
                          onSalesRepSelected: (salesRep) {
                            setState(() {
                              _selectedSalesRep = salesRep;
                            });
                          },
                        ),

                        // Step 5: Review
                        ReviewStep(
                          customer: _selectedCustomer,
                          equipmentType: _equipmentType,
                          equipmentModel: _equipmentModel,
                          equipmentSerialNumber: _equipmentSerialNumber,
                          jobDescription: _jobDescription,
                          photos: _photos,
                          salesRep: _selectedSalesRep,
                          orderDate: _orderDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Modern Navigation Footer
              Container(
                margin: EdgeInsets.all(isDesktop ? 24 : 16),
                padding: EdgeInsets.all(isDesktop ? 24 : 20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Previous Button
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.glassGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _previousStep,
                              borderRadius: BorderRadius.circular(16),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_new,
                                      color: AppColors.onSurface,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Previous',
                                      style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isDesktop ? 20 : 16),
                    ],

                    // Next/Create Button
                    Expanded(
                      flex: _currentStep > 0 ? 1 : 1,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: _canProceedToNextStep()
                              ? AppColors.primaryGradient
                              : AppColors.glassGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _canProceedToNextStep()
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading || !_canProceedToNextStep()
                                ? null
                                : _currentStep == _stepTitles.length - 1
                                    ? _createOrder
                                    : _nextStep,
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentStep == _stepTitles.length - 1
                                              ? 'Create Order'
                                              : 'Next',
                                          style: TextStyle(
                                            color: _canProceedToNextStep()
                                                ? AppColors.onPrimary
                                                : AppColors.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_currentStep <
                                            _stepTitles.length - 1) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: _canProceedToNextStep()
                                                ? AppColors.onPrimary
                                                : AppColors.onSurfaceVariant,
                                            size: 18,
                                          ),
                                        ],
                                      ],
                                    ),
                            ),
                          ),
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
    );
  }
}

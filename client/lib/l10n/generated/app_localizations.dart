import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'ProjectHub'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaces;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @onboardingTagWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'WORKSPACE & ROADMAPS'**
  String get onboardingTagWorkspaces;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ProjectHub'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your projects, organize your tasks, and collaborate with your team in one unified space.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingTagKanban.
  ///
  /// In en, this message translates to:
  /// **'AGILE WORKFLOWS'**
  String get onboardingTagKanban;

  /// No description provided for @onboardingKanbanTitle.
  ///
  /// In en, this message translates to:
  /// **'Visualize with Kanban'**
  String get onboardingKanbanTitle;

  /// No description provided for @onboardingKanbanDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep track of progress seamlessly with interactive Kanban boards and live velocity tracking.'**
  String get onboardingKanbanDesc;

  /// No description provided for @onboardingTagCollab.
  ///
  /// In en, this message translates to:
  /// **'REAL-TIME SYNC'**
  String get onboardingTagCollab;

  /// No description provided for @onboardingCollabTitle.
  ///
  /// In en, this message translates to:
  /// **'Collaborate in Real-Time'**
  String get onboardingCollabTitle;

  /// No description provided for @onboardingCollabDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with your team, sync activity instantly, and achieve your goals faster.'**
  String get onboardingCollabDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your workspace'**
  String get welcomeBackSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get started with your team and projects today'**
  String get createAccountSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNamePlaceholder;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailPlaceholder;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordPlaceholder;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @termsAndPrivacyPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get termsAndPrivacyPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! Enter your email address and we\'ll send you a password reset code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @haveResetCode.
  ///
  /// In en, this message translates to:
  /// **'Already have a reset code?'**
  String get haveResetCode;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email and choose your new password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetToken.
  ///
  /// In en, this message translates to:
  /// **'Reset Code / Token'**
  String get resetToken;

  /// No description provided for @resetTokenPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Paste code or token'**
  String get resetTokenPlaceholder;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please sign in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get nameRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @tokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the reset code'**
  String get tokenRequired;

  /// No description provided for @termsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms and Privacy Policy'**
  String get termsRequired;

  /// No description provided for @switchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch Workspace'**
  String get switchWorkspace;

  /// No description provided for @createNewWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create New Workspace'**
  String get createNewWorkspace;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create Workspace'**
  String get createWorkspace;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace Name'**
  String get workspaceName;

  /// No description provided for @workspaceNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Acme Product Team'**
  String get workspaceNamePlaceholder;

  /// No description provided for @workspaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get workspaceDescription;

  /// No description provided for @workspaceDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What is this workspace for? (optional)'**
  String get workspaceDescriptionPlaceholder;

  /// No description provided for @workspaceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a workspace name'**
  String get workspaceNameRequired;

  /// No description provided for @workspaceNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Workspace name must be 100 characters or less'**
  String get workspaceNameTooLong;

  /// No description provided for @activeWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Active Workspace'**
  String get activeWorkspace;

  /// No description provided for @otherWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Other Workspaces'**
  String get otherWorkspaces;

  /// No description provided for @noWorkspacesFound.
  ///
  /// In en, this message translates to:
  /// **'No workspaces found'**
  String get noWorkspacesFound;

  /// No description provided for @quickStartWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ProjectHub'**
  String get quickStartWelcome;

  /// No description provided for @quickStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first workspace to get started with your team.'**
  String get quickStartSubtitle;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @searchWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Search workspaces...'**
  String get searchWorkspaces;

  /// No description provided for @creatingWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Creating workspace...'**
  String get creatingWorkspace;

  /// No description provided for @workspaceSettings.
  ///
  /// In en, this message translates to:
  /// **'Workspace Settings'**
  String get workspaceSettings;

  /// No description provided for @workspaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Workspace Details'**
  String get workspaceDetails;

  /// No description provided for @saveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get saveDetails;

  /// No description provided for @detailsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Workspace details updated successfully'**
  String get detailsUpdated;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Members'**
  String membersCount(int count);

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite New Member'**
  String get inviteMember;

  /// No description provided for @inviteMemberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite someone to join this workspace. They will receive an email invitation.'**
  String get inviteMemberSubtitle;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed from workspace'**
  String get memberRemoved;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member invited to workspace'**
  String get memberAdded;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Delete Workspace'**
  String get deleteWorkspace;

  /// No description provided for @deleteWorkspaceWarning.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, this workspace and all associated projects and tasks will be permanently removed.'**
  String get deleteWorkspaceWarning;

  /// No description provided for @confirmDeleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteWorkspace;

  /// No description provided for @workspaceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workspace deleted'**
  String get workspaceDeleted;

  /// No description provided for @typeWorkspaceNameToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type \"{name}\" to confirm deletion'**
  String typeWorkspaceNameToConfirm(String name);

  /// No description provided for @ownerOnlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Only workspace owners can access settings'**
  String get ownerOnlyAccess;

  /// No description provided for @memberAddedWithEmail.
  ///
  /// In en, this message translates to:
  /// **'{email} added successfully'**
  String memberAddedWithEmail(String email);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get statusPlanning;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @projectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage workspace projects and track deliverables.'**
  String get projectsSubtitle;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjectsFound;

  /// No description provided for @noProjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get started by creating your first project in this workspace.'**
  String get noProjectsDescription;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Website Redesign'**
  String get projectNamePlaceholder;

  /// No description provided for @projectNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a project name'**
  String get projectNameRequired;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get projectDescription;

  /// No description provided for @projectDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the project goals and scope'**
  String get projectDescriptionPlaceholder;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @selectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Select due date'**
  String get selectDueDate;

  /// No description provided for @projectCreated.
  ///
  /// In en, this message translates to:
  /// **'Project created successfully'**
  String get projectCreated;

  /// No description provided for @projectUpdated.
  ///
  /// In en, this message translates to:
  /// **'Project updated successfully'**
  String get projectUpdated;

  /// No description provided for @projectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Project deleted successfully'**
  String get projectDeleted;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projectDetails;

  /// No description provided for @projectStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get projectStatus;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get createdBy;

  /// No description provided for @deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProject;

  /// No description provided for @deleteProjectWarning.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, this project and all associated tasks will be permanently removed.'**
  String get deleteProjectWarning;

  /// No description provided for @confirmDeleteProject.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteProject;

  /// No description provided for @typeProjectNameToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type \"{name}\" to confirm deletion'**
  String typeProjectNameToConfirm(String name);

  /// No description provided for @noPermissionToEditProject.
  ///
  /// In en, this message translates to:
  /// **'Only workspace owner or project creator can edit this project.'**
  String get noPermissionToEditProject;

  /// No description provided for @noPermissionToDeleteProject.
  ///
  /// In en, this message translates to:
  /// **'Only workspace owner or project creator can delete this project.'**
  String get noPermissionToDeleteProject;

  /// No description provided for @sprintOverview.
  ///
  /// In en, this message translates to:
  /// **'Sprint Overview'**
  String get sprintOverview;

  /// No description provided for @sprintOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live workspace metrics and sprint cadence'**
  String get sprintOverviewSubtitle;

  /// No description provided for @velocityBadge.
  ///
  /// In en, this message translates to:
  /// **'Sprint Velocity'**
  String get velocityBadge;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get activeProjects;

  /// No description provided for @inProgressTasks.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressTasks;

  /// No description provided for @urgentBlockers.
  ///
  /// In en, this message translates to:
  /// **'Urgent / Blockers'**
  String get urgentBlockers;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTasks;

  /// No description provided for @teamStream.
  ///
  /// In en, this message translates to:
  /// **'Team Presence & Stream'**
  String get teamStream;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet'**
  String get noRecentActivity;

  /// No description provided for @myActiveFocus.
  ///
  /// In en, this message translates to:
  /// **'My Active Focus'**
  String get myActiveFocus;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up! No active tasks assigned.'**
  String get allCaughtUp;

  /// No description provided for @activityTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'created a new task'**
  String get activityTaskCreated;

  /// No description provided for @activityTaskStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'updated task status'**
  String get activityTaskStatusChanged;

  /// No description provided for @activityTaskAssigned.
  ///
  /// In en, this message translates to:
  /// **'assigned a task'**
  String get activityTaskAssigned;

  /// No description provided for @activityTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'deleted a task'**
  String get activityTaskDeleted;

  /// No description provided for @activityProjectCreated.
  ///
  /// In en, this message translates to:
  /// **'created project'**
  String get activityProjectCreated;

  /// No description provided for @activityProjectStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'updated project status'**
  String get activityProjectStatusChanged;

  /// No description provided for @activityProjectArchived.
  ///
  /// In en, this message translates to:
  /// **'archived project'**
  String get activityProjectArchived;

  /// No description provided for @activityMemberAdded.
  ///
  /// In en, this message translates to:
  /// **'joined the workspace'**
  String get activityMemberAdded;

  /// No description provided for @activityMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'left the workspace'**
  String get activityMemberRemoved;

  /// No description provided for @activityWorkspaceCreated.
  ///
  /// In en, this message translates to:
  /// **'created this workspace'**
  String get activityWorkspaceCreated;

  /// No description provided for @activityWorkspaceUpdated.
  ///
  /// In en, this message translates to:
  /// **'updated workspace settings'**
  String get activityWorkspaceUpdated;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);

  /// No description provided for @myTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasksTitle;

  /// No description provided for @myTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal sprint backlog and assigned deliverables.'**
  String get myTasksSubtitle;

  /// No description provided for @overdueUrgent.
  ///
  /// In en, this message translates to:
  /// **'Overdue & Urgent'**
  String get overdueUrgent;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNext;

  /// No description provided for @recentlyDone.
  ///
  /// In en, this message translates to:
  /// **'Recently Done'**
  String get recentlyDone;

  /// No description provided for @noAssignedTasks.
  ///
  /// In en, this message translates to:
  /// **'No Assigned Tasks'**
  String get noAssignedTasks;

  /// No description provided for @noAssignedTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no pending tasks assigned in this workspace. Take a break or check project boards!'**
  String get noAssignedTasksSubtitle;

  /// No description provided for @kanbanBoard.
  ///
  /// In en, this message translates to:
  /// **'Kanban Board'**
  String get kanbanBoard;

  /// No description provided for @refreshBoard.
  ///
  /// In en, this message translates to:
  /// **'Refresh Board'**
  String get refreshBoard;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @archivedProjectNotice.
  ///
  /// In en, this message translates to:
  /// **'This project is archived and read-only'**
  String get archivedProjectNotice;

  /// No description provided for @noTasksInColumn.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this column'**
  String get noTasksInColumn;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @whatNeedsDone.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get whatNeedsDone;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveTo;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal settings, appearance, and active session'**
  String get profileSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @colorPalette.
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get colorPalette;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @sessionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Session & Security'**
  String get sessionSecurity;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get tabProjects;

  /// No description provided for @tabMyTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get tabMyTasks;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @statusBacklog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get statusBacklog;

  /// No description provided for @statusTodo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get statusTodo;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get statusReview;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose whether to follow device settings or lock to dark or light mode.'**
  String get appearanceSubtitle;

  /// No description provided for @colorPaletteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a curated palette to dynamically re-theme buttons, surfaces, and ambient glow.'**
  String get colorPaletteSubtitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch the application language and reading layout (LTR / RTL).'**
  String get languageSubtitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your session on this device?'**
  String get logoutConfirmation;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileRefreshed extends ProfileEvent {
  const ProfileRefreshed();
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}

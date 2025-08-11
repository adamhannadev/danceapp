class UserStatsService
  def call
    {
      total_users: User.count,
      students_count: User.students.count,
      instructors_count: User.instructors.count,
      admins_count: User.admins.count,
      members_count: User.with_membership.count
    }
  end
end

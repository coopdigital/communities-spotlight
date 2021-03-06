require 'intercom'

class IntercomSubmission

  def self.process!(submission, form)
    if Rails.application.secrets.intercom_key
      intercom = Intercom::Client.new(token: Rails.application.secrets.intercom_key);
      submission_interests = {}
      submission.interests.thumbs_up.each_with_index do |interest, index|
        submission_interests[:"activity_#{index+1}"] = interest.activity.name
      end
      basic_attributes = {
        name: form.name,
        email: form.email,
        custom_attributes: {
          latest_submission: submission.uuid,
          location: submission.location.to_s,
          involvement: submission.involvement.to_s,
          activity_suggestion: submission.activity_suggestion
        }.merge(submission_interests)
      }
      user = intercom.users.create(basic_attributes.merge(user_id: submission.member.uuid))
      submission.member.update(intercom_id: user.id)
    else
      submission.member.update(intercom_id: 'test_environment')
    end
  end
end

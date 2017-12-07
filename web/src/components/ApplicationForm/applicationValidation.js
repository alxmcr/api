import { createValidator, required, email } from 'utils/validation'

export default createValidator({
  first_name: [required],
  last_name: [required],
  email: [required, email],
  high_school: [required],
  year: [required],
  interesting_project: [required],
  systems_hacked: [required],
  steps_taken: [required],
  referer: [required]
})

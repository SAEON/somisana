import { lazy } from 'react'
import {Cog} from '../../../components/icons'
import Transition from '../../../components/page-transition'

const HomePage = lazy(() => import('./home'))
const PrivacyPolicyPage = lazy(() => import('../../../modules/privacy-policy'))

export default [
  {
    label: 'Home',
    to: '/',
    includeInFooter: true,
    exact: true,
    Icon: Cog,
    render: () => (
      <Transition>
        <HomePage />
      </Transition>
    ),
  },


  {
    label: 'Privacy policy',
    Icon: Cog,
    exact: true,
    group: 'legal',
    render: () => (
      <Transition>
        <PrivacyPolicyPage />
      </Transition>
    ),
    to: '/privacy-policy',
    excludeFromNav: true,
    includeInFooter: true,
  }
]

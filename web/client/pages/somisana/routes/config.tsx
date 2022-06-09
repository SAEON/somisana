import { lazy, Suspense } from 'react'
import Loading from '../../../components/loading'
import { Cog } from '../../../components/icons'
import HomePage from './home'

const PrivacyPolicyPage = lazy(() => import('../../../modules/privacy-policy'))

export default [
  {
    to: '/',
    path: '*',
    label: 'Home',
    Icon: Cog,
    includeInNavMenu: true,
    element: () => <HomePage />,
  },

  {
    to: '/privacy-policy',
    path: '/privacy-policy',
    label: 'Privacy policy',
    Icon: Cog,
    includeInNavMenu: true,
    element: () => (
      <Suspense fallback={<Loading />}>
        <PrivacyPolicyPage />
      </Suspense>
    ),
  },
]

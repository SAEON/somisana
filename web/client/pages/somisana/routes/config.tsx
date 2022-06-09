import { lazy, Suspense } from 'react'
import Loading from '../../../components/loading'
import { Home, Contract, Map } from '../../../components/icons'
import HomePage from './home'

const PrivacyPolicyPage = lazy(() => import('../../../modules/privacy-policy'))
const AtlasPage = lazy(() => import('../../atlas/ssr'))

export default [
  {
    to: '/',
    path: '*',
    label: 'Home',
    Icon: Home,
    includeInNavMenu: true,
    element: () => <HomePage />,
  },

  {
    to: '/visualizations',
    path: '/visualizations',
    label: 'Atlas',
    Icon: Map,
    includeInNavMenu: true,
    element: () => (
      <Suspense fallback={<Loading />}>
        <AtlasPage />
      </Suspense>
    ),
  },

  {
    to: '/privacy-policy',
    path: '/privacy-policy',
    label: 'Privacy policy',
    Icon: Contract,
    includeInNavMenu: true,
    element: () => (
      <Suspense fallback={<Loading />}>
        <PrivacyPolicyPage />
      </Suspense>
    ),
  },
]

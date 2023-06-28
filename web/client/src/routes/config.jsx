import { lazy, Suspense } from 'react'
import { Linear as LinearLoading, Circular as CircularLoading } from '../components/loading'
import {
  Home,
  Contract,
  Map,
  Github,
  License,
  Link,
} from  '../components/icons'
import { gql, useQuery } from '@apollo/client'
import HomePage from './home'
import Div from '../components/div'

const PrivacyPolicyPage = lazy(() => import('./privacy-policy'))
const ExplorePage = lazy(() => import('./explore'))
const ExploreModelPage = lazy(() => import('./model'))

const L = ({ sx = {}, ...props }) => (
  <Div sx={{ flex: 1 }}>
    <LinearLoading sx={{ width: '100%', ...sx }} {...props} />
  </Div>
)

export const dictionary = {
  woes: 'WOES',
  sst: 'SST',
}

export default [
  {
    to: '/',
    path: '*',
    label: 'Home',
    Icon: Home,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => <HomePage {...props} />,
  },
  

  {
    to: '/explore/:id',
    path: '/explore/:id',
    label: 'Model',
    BreadcrumbsLabel: ({ pathname }) => {
      const { error, loading, data } = useQuery(
        gql`
          query ($id: ID) {
            models(id: $id) {
              id
              _id
              title
            }
          }
        `,
        {
          variables: {
            id: pathname.match(/\d+$/)?.[0],
          },
        }
      )

      if (loading) {
        return <CircularLoading size={16} />
      }

      if (error) {
        throw error
      }

      return data.models[0].title
    },
    includeInNavMenu: false,
    includeInFooter: false,
    element: props => (
      <Suspense fallback={<L />}>
        <ExploreModelPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/explore',
    path: '/explore',
    label: 'Explore',
    Icon: Map,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => (
      <Suspense fallback={<L />}>
        <ExplorePage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/privacy-policy',
    path: '/privacy-policy',
    label: 'Privacy policy',
    group: 'legal',
    includeInFooter: true,
    includeInNavMenu: false,
    Icon: Contract,
    element: props => (
      <Suspense fallback={<L />}>
        <PrivacyPolicyPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'Source code',
    Icon: Github,
    href: 'https://github.com/SAEON/somisana',
    includeInNavMenu: false,
    includeInFooter: true,
  },
  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'License (MIT)',
    Icon: License,
    includeInNavMenu: false,
    includeInFooter: true,
    href: 'https://github.com/SAEON/somisana/blob/stable/LICENSE',
  },

  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'flagpedia.net',
    Icon: Link,
    includeInNavMenu: false,
    includeInFooter: true,
    href: 'https://flagpedia.net',
  },
]
